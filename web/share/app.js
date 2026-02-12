// Firebase configuration will be injected by the hosting setup
// This file handles the shared group expense view

const firebaseConfig = {
  apiKey: "AIzaSyAoqFq_wt5gYw7LXW6zJg9bTJaVf-A7Bq4",
  authDomain: "splitexpenses-4c618.firebaseapp.com",
  projectId: "splitexpenses-4c618",
  storageBucket: "splitexpenses-4c618.firebasestorage.app",
  messagingSenderId: "533009234467",
  appId: "1:533009234467:web:95ad5e7976e9c80e094655",
  measurementId: "G-TNZS9NHRG4"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();

// Get eventId and shareToken from URL
const urlParams = new URLSearchParams(window.location.search);
const eventId = urlParams.get('id');
const shareToken = urlParams.get('token');

if (!eventId || !shareToken) {
  document.getElementById('error-message').textContent = 'Invalid share link';
  document.getElementById('error-section').style.display = 'block';
  document.getElementById('loading').style.display = 'none';
} else {
  loadEventData();
}

// Real-time listener for event data
let unsubscribe = null;

function loadEventData() {
  // Set up real-time listener
  unsubscribe = db.collection('events')
    .doc(eventId)
    .onSnapshot(async (eventDoc) => {
      if (!eventDoc.exists) {
        showError('Group expense not found');
        return;
      }

      const event = eventDoc.data();
      
      // Verify share token
      if (event.shareToken !== shareToken) {
        showError('Invalid share token');
        return;
      }

      // Load participants
      const participantIds = event.participantIds || [];
      const participants = {};
      
      for (const participantId of participantIds) {
        const participantDoc = await db.collection('participants').doc(participantId).get();
        if (participantDoc.exists) {
          participants[participantId] = participantDoc.data();
        }
      }

      // Load expenses with real-time updates
      db.collection('expenses')
        .where('eventId', '==', eventId)
        .orderBy('timestamp', 'desc')
        .onSnapshot((expensesSnapshot) => {
          const expenses = [];
          expensesSnapshot.forEach((doc) => {
            expenses.push({ id: doc.id, ...doc.data() });
          });

          renderEventData(event, participants, expenses);
        });
    }, (error) => {
      console.error('Error loading event:', error);
      showError('Error loading group expense data');
    });
}

function renderEventData(event, participants, expenses) {
  document.getElementById('loading').style.display = 'none';
  document.getElementById('content').style.display = 'block';

  // Group info
  document.getElementById('group-name').textContent = event.name || 'Unnamed Group';
  if (event.description) {
    document.getElementById('group-description').textContent = event.description;
    document.getElementById('group-description').style.display = 'block';
  }

  const currency = getCurrencySymbol(event.currency || 'USD');
  
  // Participant list
  const participantsList = document.getElementById('participants-list');
  participantsList.innerHTML = '';
  
  Object.values(participants).forEach(participant => {
    const chip = document.createElement('span');
    chip.className = 'participant-chip';
    chip.innerHTML = `
      <span class="participant-avatar">${participant.name[0].toUpperCase()}</span>
      <span>${participant.name}</span>
    `;
    participantsList.appendChild(chip);
  });

  // Calculate totals
  const totals = calculateTotals(expenses, participants, event);
  
  // Display total expenses
  document.getElementById('total-expenses').textContent = formatCurrency(totals.totalAmount, currency);
  document.getElementById('total-count').textContent = `${expenses.length} ${expenses.length === 1 ? 'expense' : 'expenses'}`;

  // Expenses list
  renderExpenses(expenses, participants, currency);
  
  // Balances
  renderBalances(totals, participants, currency);
  
  // Settlement summary
  renderSettlement(totals, participants, currency);
}

function renderExpenses(expenses, participants, currency) {
  const expensesList = document.getElementById('expenses-list');
  expensesList.innerHTML = '';

  if (expenses.length === 0) {
    expensesList.innerHTML = '<div class="empty-state">No expenses added yet</div>';
    return;
  }

  expenses.forEach(expense => {
    const paidBy = participants[expense.paidByParticipantId];
    const date = new Date(expense.timestamp.toDate());
    
    const expenseCard = document.createElement('div');
    expenseCard.className = 'expense-card';
    expenseCard.innerHTML = `
      <div class="expense-header">
        <div class="expense-amount">${formatCurrency(expense.amount, currency)}</div>
        <div class="expense-category">${getCategoryIcon(expense.category)} ${formatCategory(expense.category)}</div>
      </div>
      <div class="expense-description">${expense.description || 'No description'}</div>
      <div class="expense-meta">
        <div>Paid by <strong>${paidBy ? paidBy.name : 'Unknown'}</strong></div>
        <div class="expense-date">${formatDate(date)}</div>
      </div>
      ${expense.notes ? `<div class="expense-notes">${expense.notes}</div>` : ''}
      <div class="expense-split">${formatSplitMethod(expense.splitMethod)}</div>
    `;
    expensesList.appendChild(expenseCard);
  });
}

function renderBalances(totals, participants, currency) {
  const balancesList = document.getElementById('balances-list');
  balancesList.innerHTML = '';

  const sortedParticipants = Object.entries(totals.balances)
    .sort(([, a], [, b]) => b - a);

  sortedParticipants.forEach(([participantId, balance]) => {
    const participant = participants[participantId];
    if (!participant) return;

    const balanceCard = document.createElement('div');
    balanceCard.className = `balance-card ${balance > 0 ? 'positive' : balance < 0 ? 'negative' : 'neutral'}`;
    balanceCard.innerHTML = `
      <div class="balance-name">
        <span class="participant-avatar">${participant.name[0].toUpperCase()}</span>
        <span>${participant.name}</span>
      </div>
      <div class="balance-amounts">
        <div class="balance-paid">Paid: ${formatCurrency(totals.paid[participantId] || 0, currency)}</div>
        <div class="balance-owed">Share: ${formatCurrency(totals.owed[participantId] || 0, currency)}</div>
      </div>
      <div class="balance-net ${balance > 0 ? 'positive' : balance < 0 ? 'negative' : 'neutral'}">
        ${balance > 0 ? 'Gets back' : balance < 0 ? 'Owes' : 'Settled'}: 
        <strong>${formatCurrency(Math.abs(balance), currency)}</strong>
      </div>
    `;
    balancesList.appendChild(balanceCard);
  });
}

function renderSettlement(totals, participants, currency) {
  const settlementList = document.getElementById('settlement-list');
  settlementList.innerHTML = '';

  const transactions = calculateSettlementTransactions(totals, participants);

  if (transactions.length === 0) {
    settlementList.innerHTML = '<div class="empty-state">All settled!</div>';
    return;
  }

  transactions.forEach(transaction => {
    const fromParticipant = participants[transaction.from];
    const toParticipant = participants[transaction.to];
    
    const transactionCard = document.createElement('div');
    transactionCard.className = 'settlement-card';
    transactionCard.innerHTML = `
      <div class="settlement-from">${fromParticipant ? fromParticipant.name : 'Unknown'}</div>
      <div class="settlement-arrow">→</div>
      <div class="settlement-to">${toParticipant ? toParticipant.name : 'Unknown'}</div>
      <div class="settlement-amount">${formatCurrency(transaction.amount, currency)}</div>
    `;
    settlementList.appendChild(transactionCard);
  });
}

function calculateTotals(expenses, participants, event) {
  const paid = {};
  const owed = {};
  let totalAmount = 0;

  // Initialize
  Object.keys(participants).forEach(id => {
    paid[id] = 0;
    owed[id] = 0;
  });

  // Calculate from expenses
  expenses.forEach(expense => {
    totalAmount += expense.amount;
    paid[expense.paidByParticipantId] = (paid[expense.paidByParticipantId] || 0) + expense.amount;

    // Calculate how much each person owes
    if (expense.splitMethod === 'equal') {
      const participantCount = Object.keys(participants).length;
      const sharePerPerson = expense.amount / participantCount;
      Object.keys(participants).forEach(id => {
        owed[id] = (owed[id] || 0) + sharePerPerson;
      });
    } else if (expense.splitDetails) {
      // Use splitDetails (which is a map of participantId to share ratio)
      Object.entries(expense.splitDetails).forEach(([participantId, share]) => {
        owed[participantId] = (owed[participantId] || 0) + (expense.amount * share);
      });
    }
  });

  // Calculate net balances
  const balances = {};
  Object.keys(participants).forEach(id => {
    balances[id] = (paid[id] || 0) - (owed[id] || 0);
  });

  return { paid, owed, balances, totalAmount };
}

function calculateSettlementTransactions(totals, participants) {
  const transactions = [];
  const balances = { ...totals.balances };

  // Simple greedy algorithm for settlements
  while (true) {
    const creditors = Object.entries(balances).filter(([, amt]) => amt > 0.01).sort(([, a], [, b]) => b - a);
    const debtors = Object.entries(balances).filter(([, amt]) => amt < -0.01).sort(([, a], [, b]) => a - b);

    if (creditors.length === 0 || debtors.length === 0) break;

    const [creditorId, creditorAmt] = creditors[0];
    const [debtorId, debtorAmt] = debtors[0];

    const amount = Math.min(creditorAmt, Math.abs(debtorAmt));
    
    transactions.push({
      from: debtorId,
      to: creditorId,
      amount: amount
    });

    balances[creditorId] -= amount;
    balances[debtorId] += amount;
  }

  return transactions;
}

function formatCurrency(amount, symbol) {
  return `${symbol}${amount.toFixed(2)}`;
}

function getCurrencySymbol(code) {
  const symbols = {
    'USD': '$', 'EUR': '€', 'GBP': '£', 'JPY': '¥',
    'INR': '₹', 'AUD': 'A$', 'CAD': 'C$', 'CHF': 'Fr',
    'CNY': '¥', 'SEK': 'kr', 'NZD': 'NZ$'
  };
  return symbols[code] || '$';
}

function formatCategory(category) {
  return category.charAt(0).toUpperCase() + category.slice(1);
}

function getCategoryIcon(category) {
  const icons = {
    'food': '🍽️',
    'transport': '🚗',
    'accommodation': '🏨',
    'utilities': '⚡',
    'groceries': '🛒',
    'entertainment': '🎬',
    'shopping': '🛍️',
    'healthcare': '🏥',
    'general': '📝',
    'other': '📌'
  };
  return icons[category] || '📌';
}

function formatSplitMethod(method) {
  const methods = {
    'equal': 'Split Equally',
    'percentage': 'Split by Percentage',
    'exactAmounts': 'Exact Amounts',
    'shares': 'Custom Shares'
  };
  return methods[method] || 'Split Equally';
}

function formatDate(date) {
  const now = new Date();
  const diffMs = now - date;
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);

  if (diffMins < 1) return 'Just now';
  if (diffMins < 60) return `${diffMins}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays < 7) return `${diffDays}d ago`;
  
  return date.toLocaleDateString();
}

function showError(message) {
  document.getElementById('loading').style.display = 'none';
  document.getElementById('error-message').textContent = message;
  document.getElementById('error-section').style.display = 'block';
}

// Clean up listener when page unloads
window.addEventListener('beforeunload', () => {
  if (unsubscribe) {
    unsubscribe();
  }
});
