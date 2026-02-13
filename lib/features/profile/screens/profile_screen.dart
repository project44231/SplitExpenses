import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
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
  ExpenseStats? _stats;

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

      // Load events directly from Firebase only (not local storage)
      final firestoreService = FirestoreService();
      final allEvents = await firestoreService.getEvents(userId);

      final stats = await _calculateExpenseStats(allEvents, firestoreService);

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

  Future<ExpenseStats> _calculateExpenseStats(List<Event> events, FirestoreService firestoreService) async {
    if (events.isEmpty) {
      return ExpenseStats(
        eventsCreated: 0,
        totalExpenses: 0,
        totalAmount: 0.0,
        totalParticipants: 0,
        lastEventDate: null,
      );
    }

    int totalExpenses = 0;
    double totalAmount = 0.0;
    Set<String> uniqueParticipants = {};
    DateTime? lastEventDate;

    for (final event in events) {
      // Get expenses for this event
      final expenses = await firestoreService.getExpenses(event.id);
      totalExpenses += expenses.length;
      
      // Sum up all expense amounts
      for (final expense in expenses) {
        totalAmount += expense.amount;
        
        // Track unique participants
        uniqueParticipants.add(expense.paidByParticipantId);
        uniqueParticipants.addAll(expense.splitDetails.keys);
      }
      
      // Track most recent event
      if (lastEventDate == null || event.startTime.isAfter(lastEventDate)) {
        lastEventDate = event.startTime;
      }
    }

    return ExpenseStats(
      eventsCreated: events.length,
      totalExpenses: totalExpenses,
      totalAmount: totalAmount,
      totalParticipants: uniqueParticipants.length,
      lastEventDate: lastEventDate,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'images/app_icon.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
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
                  'Access expense history, statistics, participant contacts, and sync your data across devices by signing in.',
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'images/app_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
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

                  // Expense Statistics Card
                  _buildExpenseStatsCard(),
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

  Widget _buildExpenseStatsCard() {
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
                  'Expense Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildStatRow(
              'Events Created',
              '${_stats!.eventsCreated}',
              Icons.event,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'Total Expenses',
              '${_stats!.totalExpenses}',
              Icons.receipt_long,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'Total Amount Tracked',
              Formatters.formatCurrency(_stats!.totalAmount, AppCurrencies.usd),
              Icons.attach_money,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'Total Participants',
              '${_stats!.totalParticipants}',
              Icons.people,
            ),
            if (_stats!.lastEventDate != null) ...[
              const Divider(height: 24),
              _buildStatRow(
                'Last Event',
                Formatters.formatDate(_stats!.lastEventDate!),
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
            title: const Text('Participant Contacts'),
            subtitle: const Text('Manage your participant list'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push(AppConstants.playerContactsRoute);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings, color: AppTheme.primaryColor),
            title: const Text('App Settings'),
            subtitle: const Text('Default currency and preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAppSettingsDialog,
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

  void _showAppSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Settings'),
        content: const Text(
          'Default currency and expense preferences customization coming soon.',
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
          'Split expenses with friends and groups effortlessly. '
          'Track expenses, manage participants, calculate settlements, and view event history all in one place.',
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out? All local data will be cleared.'),
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
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      try {
        // Sign out (this will clear all local data)
        await ref.read(authServiceProvider).signOut();
        
        // Clear auth state
        ref.invalidate(authNotifierProvider);
        
        if (mounted) {
          // Close loading dialog
          Navigator.of(context).pop();
          
          // Navigate to auth screen, replacing the entire navigation stack
          context.go(AppConstants.authRoute);
        }
      } catch (e) {
        if (mounted) {
          // Close loading dialog
          Navigator.of(context).pop();
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign out failed: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }
}

class ExpenseStats {
  final int eventsCreated;
  final int totalExpenses;
  final double totalAmount;
  final int totalParticipants;
  final DateTime? lastEventDate;

  ExpenseStats({
    required this.eventsCreated,
    required this.totalExpenses,
    required this.totalAmount,
    required this.totalParticipants,
    required this.lastEventDate,
  });
}
