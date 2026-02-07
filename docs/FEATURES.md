# Poker Home Game Tracker - App Features

## Overview
A mobile app to track poker buy-ins for home cash games with support for multiple game groups, optimized settlements, and comprehensive statistics.

## ✅ Implemented Features (MVP v0.1)

### Authentication & Guest Mode ✅
- Continue as Guest (no login required)
- Local data storage with Hive
- Auto-remembers login state
- Ready for Firebase Auth integration (Google, Apple, Email)

### Player Management ✅
- Add new players with name
- Search existing players
- Player list with avatar initials
- Auto-generated player IDs

### Game Creation ✅
- Multi-select players for a game
- Currency selection (8 supported: USD, EUR, GBP, CAD, AUD, JPY, INR, CNY)
- Optional game notes
- Automatic "Quick Games" group creation
- Start game with validation

### Active Game Tracking ✅
- **Live game timer** (HH:MM:SS format)
- **Total pot display** with currency formatting
- **Player buy-in cards** showing:
  - Player avatar
  - Current total buy-in
  - Rebuy count
- **Add buy-in dialog** with:
  - Player selection dropdown
  - Amount input with validation
  - Quick amount buttons ($20/$50/$100/$200)
  - Type selection (Initial/Rebuy)
- **Pull-to-refresh** to update game state
- **End game** with confirmation dialog
- **Buy-in counter** at bottom

### Settlement & Cash-Out ✅
- **Cash-out entry dialog** with:
  - Player-by-player cash-out amounts
  - Real-time total validation
  - Quick buttons (Break Even, 2x, Bust)
  - Mismatch warning display
- **Player results summary**:
  - Sorted by profit/loss
  - Profit/loss with color coding (green/red)
  - Buy-in and cash-out breakdown
  - Trending icons (up/down)
- **Optimized settlement algorithm**:
  - Debt simplification to minimize transfers
  - Example: 4 players, 6 possible transfers → optimized to 2-3
  - Handles decimal precision
  - Transaction counter badge
- **Settlement display**:
  - "Who owes whom" transaction cards
  - Visual flow (from → amount → to)
  - Color-coded avatars (red for payer, green for receiver)
- **Share functionality**:
  - Generate shareable text summary
  - Includes results and settlement details
  - Share via SMS/messaging apps
- **Edit capability**: Modify cash-outs if needed

---

## Core Features

### 1. Game Management
- Create new cash game sessions
- Manage multiple game groups (different friend groups, locations)
- Game status: Active, Ended, Archived
- Quick start game with default players

### 2. Player Management
- Player database (name, contact info, profile pic optional)
- Add players to a specific game group
- Mark players as active/inactive for each game
- Player search and filtering

### 3. Live Buy-In Tracking (During Game)
- **Add initial buy-ins** as players arrive
- **Multiple rebuys per player** (unlimited, timestamp each)
- Visual list of all players with running totals
- Quickly see:
  - Total money on the table
  - Each player's total buy-in amount
  - Number of rebuys per player
  - Game timer (duration)

### 4. Cash-Out & Settlement
- **End game workflow:**
  - Enter final chip counts OR cash-out amounts for each player
  - Automatic profit/loss calculation
  - **Optimized settlement algorithm** (minimize transactions)
    - Shows who pays whom and how much
    - Example: Instead of 4 transactions, optimizes to 2
  - Export/share settlement summary (text, PDF, or image)

### 5. Expense Tracking
- Add game expenses (food, drinks, supplies)
- Flexible split options per game:
  - Host absorbs cost
  - Split equally among all players
  - Custom split (select which players chip in)
- Integrate expenses into final settlement

### 6. History & Statistics

**Game History:**
- List of all past games (filterable by date, game group)
- Game details: date, duration, players, buy-ins, results
- Search and filter games

**Player Statistics (Per Game Group):**
- Total games played
- Total profit/loss
- Average profit per game
- Win rate (percentage of profitable sessions)
- Biggest win/loss
- ROI (return on investment)
- Total money wagered
- Trend charts (profit over time)

**Leaderboards:**
- Biggest winner (total profit)
- Most profitable player (ROI)
- Most games played
- Biggest single-game win
- Filter by time period (all-time, year, month)

### 7. Data & Export
- Export game summary as:
  - Text message
  - PDF report
  - CSV for spreadsheets
- Share settlement details directly to players via SMS/messaging apps
- Local data storage (no login required)
- Optional cloud backup for peace of mind

---

## User Experience Features

### 8. Quick Actions
- "Start New Game" with last game's players pre-selected
- "Rebuy" button for quick additional buy-ins
- Swipe gestures for common actions
- Dark mode (for late-night games)

### 9. Validation & Safety
- Confirm before ending a game
- Warn if cash-outs don't match total buy-ins
- Prevent accidental data deletion
- Undo last action

### 10. Dashboard/Home Screen
- Upcoming/active games
- Quick stats summary
- Recent game results
- Quick access to most-used game groups

---

## Nice-to-Have / Future Features

11. **Game Templates** - Save game settings (stakes, blinds, typical players) for recurring games
12. **Notifications** - Remind yourself to settle up with players
13. **Photos** - Attach winner photos or table shots to games
14. **Notes** - Add memorable hands or funny moments to game records
15. **Multi-currency support** - If you travel or have international games
16. **Offline mode** - Full functionality without internet

---

## Open Questions

1. **Stakes/Blinds tracking** - Do you want to track what stakes you're playing (e.g., $1/$2), or is that not important?

2. **Pre-game setup** - Do you want to be able to invite/remind players before a game, or is this purely for tracking during/after?

3. **UI preference** - Do you prefer a clean, minimal interface or something more visually rich (card themes, poker chip graphics)?

4. **Platform** - You mentioned Flutter (iOS + Android). Do you also want a web version for desktop access, or mobile-only is fine?

5. **Rake/Host fee** - Some home games charge a small rake or host fee. Need to track that?

6. **Integration approach** - Do you want this as a **native Flutter app** OR use a **WebView-based approach** where you control everything from a web page?

---

## Decisions Made (Based on Initial Questions)

- **Game Type**: Cash games only
- **User Roles**: Host-only app (not multiplayer)
- **Settlement**: Optimized settlements (minimize transactions)
- **History/Stats**: Full statistics, player stats, and leaderboards
- **Game Groups**: Multiple game groups support
- **Rebuys**: Common - full support for multiple rebuys
- **Chip Management**: Direct dollar amounts (no chip conversion)
- **During Game Tracking**: Live buy-in tracking
- **End Game**: Full settlement, profit/loss, and export capabilities
- **Additional**: Expense tracking with flexible splitting
- **Data Privacy**: Not sensitive - cloud backup OK
- **Existing History**: Starting fresh (no import needed)
