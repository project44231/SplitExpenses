import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/compat.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../widgets/edit_profile_dialog.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  HostingStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      
      // Get current user ID
      final userId = authService.currentUserId;
      if (userId == null || authService.isGuestMode) {
        setState(() => _isLoading = false);
        return;
      }

      // Load games directly from Firebase only (not local storage)
      final firestoreService = FirestoreService();
      final allGames = await firestoreService.getEvents(userId);

      final stats = _calculateHostingStats(allGames);

      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  HostingStats _calculateHostingStats(List<Game> games) {
    final endedGames = games.where((g) => g.status == EventStatus.settled || g.status == EventStatus.archived).toList();
    
    if (endedGames.isEmpty) {
      return HostingStats(
        gamesHosted: 0,
        totalPlayers: 0,
        totalMoneyMoved: 0.0,
        avgDuration: Duration.zero,
        lastGameDate: null,
      );
    }

    int totalPlayers = 0;
    double totalMoneyMoved = 0.0;
    Duration totalDuration = Duration.zero;
    DateTime? lastGameDate;

    for (final game in endedGames) {
      totalPlayers += game.playerIds.length.toInt();
      
      // Calculate duration
      if (game.endTime != null) {
        totalDuration += game.endTime!.difference(game.startTime);
        
        // Track most recent game
        if (lastGameDate == null || game.endTime!.isAfter(lastGameDate)) {
          lastGameDate = game.endTime;
        }
      }
    }

    // Average duration
    final avgDuration = endedGames.isNotEmpty
        ? Duration(milliseconds: totalDuration.inMilliseconds ~/ endedGames.length)
        : Duration.zero;

    return HostingStats(
      gamesHosted: endedGames.length,
      totalPlayers: totalPlayers,
      totalMoneyMoved: totalMoneyMoved,
      avgDuration: avgDuration,
      lastGameDate: lastGameDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.getCurrentUser();

    // Guest user view
    if (authService.isGuestMode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'Sign In for More Features',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Access game history, statistics, player contacts, and more by signing in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Sign out guest user first, then go to auth
                    await ref.read(authServiceProvider).signOut();
                    if (mounted) {
                      context.go('/auth');
                    }
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text('Sign In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Authenticated user view
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // User Info Card
                  _buildUserInfoCard(user),
                  const SizedBox(height: 16),

                  // Hosting Statistics Card
                  _buildHostingStatsCard(),
                  const SizedBox(height: 16),

                  // App Settings Card
                  _buildAppSettingsCard(),
                  const SizedBox(height: 16),

                  // About Card
                  _buildAboutCard(),
                  const SizedBox(height: 16),

                  // Sign Out Button
                  _buildSignOutButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoCard(user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile photo
            CircleAvatar(
              radius: 40,
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              child: user?.photoUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primaryColor,
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Display name
            Text(
              user?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Edit Profile Button
            OutlinedButton.icon(
              onPressed: _showEditProfileDialog,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostingStatsCard() {
    if (_stats == null) {
      return const SizedBox();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Hosting Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildStatRow(
              'Games Hosted',
              '${_stats!.gamesHosted}',
              Icons.sports_esports,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'Total Players',
              '${_stats!.totalPlayers}',
              Icons.people,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'Avg Game Duration',
              '${_stats!.avgDuration.inHours}h ${_stats!.avgDuration.inMinutes % 60}m',
              Icons.timer,
            ),
            if (_stats!.lastGameDate != null) ...[
              const Divider(height: 24),
              _buildStatRow(
                'Last Game',
                Formatters.formatDate(_stats!.lastGameDate!),
                Icons.calendar_today,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAppSettingsCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.contacts, color: AppTheme.primaryColor),
            title: const Text('Player Contacts'),
            subtitle: const Text('Manage your player list'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push(AppConstants.playerContactsRoute);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings, color: AppTheme.primaryColor),
            title: const Text('Game Settings'),
            subtitle: const Text('Default currency and buy-in amounts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showGameSettingsDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.storage, color: AppTheme.primaryColor),
            title: const Text('Data Management'),
            subtitle: const Text('Export or delete your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showDataManagementDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info, color: AppTheme.primaryColor),
            title: const Text('App Version'),
            trailing: Text(
              AppConstants.appVersion,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description, color: AppTheme.primaryColor),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: _signOut,
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final authService = ref.read(authServiceProvider);
    final user = authService.getCurrentUser();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => EditProfileDialog(
        currentName: user?.displayName ?? '',
      ),
    );

    if (result != null && mounted) {
      // Update profile (would need to implement updateProfile in AuthService)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile update coming soon')),
      );
    }
  }

  void _showGameSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Settings'),
        content: const Text(
          'Default currency and buy-in amount customization coming soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDataManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Management'),
        content: const Text(
          'Export and delete data features coming soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Image.asset(
        'images/app_icon.png',
        width: 64,
        height: 64,
      ),
      children: [
        const Text(
          'Track poker buy-ins for home games with ease. '
          'Manage players, settlements, and view game history all in one place.',
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authServiceProvider).signOut();
      if (mounted) {
        context.go('/auth');
      }
    }
  }
}

class HostingStats {
  final int gamesHosted;
  final int totalPlayers;
  final double totalMoneyMoved;
  final Duration avgDuration;
  final DateTime? lastGameDate;

  HostingStats({
    required this.gamesHosted,
    required this.totalPlayers,
    required this.totalMoneyMoved,
    required this.avgDuration,
    required this.lastGameDate,
  });
}
