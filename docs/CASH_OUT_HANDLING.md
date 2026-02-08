# Cash-Out Mismatch Handling

## Overview

This document explains how the app handles different cash-out vs buy-in scenarios when ending a game.

## Features Implemented

### 1. Mismatch Detection
- **Perfect Match** (±$0.01): Green banner, direct path to settlement
- **Acceptable** (< $10 AND < 2%): Blue info banner, can proceed
- **Warning - Shortage** (buy-in > cash-out): Orange warning with multiple options
- **Critical - Excess** (cash-out > buy-in): Red error with corrective actions

### 2. Severity Levels

```dart
enum MismatchSeverity {
  perfect,        // ±$0.01 tolerance
  acceptable,     // < $10 AND < 2%
  warningShortage,  // buy-in > cash-out
  criticalExcess,   // cash-out > buy-in (ERROR)
}
```

### 3. Action Options

#### For Shortage (Missing Money)
1. **Add Expense Entry**
   - Record tips, food, or other expenses
   - Explains the discrepancy
   - Saves to Firestore
   - Categories: Tips, Food & Drinks, Other

2. **Adjust Cash-Outs**
   - **Distribute Among Losers** (proportional)
   - **Manual Selection** (choose specific players)
   - Shows preview before applying
   - Saves reconciliation record

3. **Continue As-Is**
   - Proceeds with mismatch
   - Requires confirmation
   - Adds note to game record
   - Settlement may not balance perfectly

#### For Excess (Extra Money - Critical)
1. **Go Back to Game**
   - Returns to active game screen
   - Game stays active
   - Add missing buy-ins
   - Return to cash-out when ready

2. **Add Buy-Ins**
   - Dialog to add missing buy-ins
   - Select players and amounts
   - Updates game total
   - Re-checks match status

3. **Adjust Cash-Outs**
   - **Reduce From Winners** (proportional)
   - **Manual Selection** (choose specific players)
   - Shows preview before applying
   - Saves reconciliation record

## User Experience Flow

```
1. User enters cash-out amounts
   ↓
2. App calculates mismatch severity
   ↓
3. Shows appropriate banner (green/orange/red)
   ↓
4. User selects action
   ↓
5. Action executed (expense/adjustment/continue)
   ↓
6. Game ends → Settlement calculated
```

## Technical Components

### Services
- `CashOutMismatchHandler`: Detects and categorizes mismatches
- `CashOutAdjustmentService`: Proportional distribution algorithms
- `FirestoreService`: Saves expenses and reconciliations

### Widgets
- `MismatchBanner`: Dynamic banner with action buttons
- `ExpenseDialog`: Add expense entries
- `AdjustmentDialog`: Adjust cash-outs with preview

### Models
- `Expense`: Expense records
- `CashOutReconciliation`: Adjustment history
- `ExpenseCategory`: Tips, Food, Other
- `ReconciliationType`: Type of reconciliation

## Data Persistence

All actions are saved to Firestore:
- Expenses → `expenses` collection
- Reconciliations → `reconciliations` collection
- Includes userId for guest/authenticated tracking

## Validation

- Cash-out amounts must be non-negative
- Expense amounts must be positive
- All changes are validated before saving

## Future Enhancements

1. Bulk cash-out entry (enter all at once)
2. Import cash-outs from external source
3. Auto-suggest based on buy-in totals
4. Historical expense patterns
5. Per-player expense splitting
