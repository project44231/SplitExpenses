// Firebase configuration
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js';
import { getFirestore, doc, getDoc, collection, query, where, getDocs, onSnapshot } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js';

// Your Firebase configuration
const firebaseConfig = {
    apiKey: "AIzaSyD9Sq5zKp0z_kS3E2Dw3HVJ0bKLLq0sQUg",
    authDomain: "gametracker-a834b.firebaseapp.com",
    projectId: "gametracker-a834b",
    storageBucket: "gametracker-a834b.firebasestorage.app",
    messagingSenderId: "396662693516",
    appId: "1:396662693516:web:1a0e2b96b3f1b3c8e8b3c8"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Get game ID and token from URL
const pathParts = window.location.pathname.split('/');
const gameId = pathParts[2];
const shareToken = pathParts[3];

// Cache for player names
let playersCache = {};

// Main function
async function loadGame() {
    try {
        // Validate URL parameters
        if (!gameId || !shareToken) {
            showError('Invalid share link. Please check the URL.');
            return;
        }

        // Load game document
        const gameDoc = await getDoc(doc(db, 'games', gameId));
        
        if (!gameDoc.exists()) {
            showError('Game not found.');
            return;
        }

        const game = gameDoc.data();

        // Validate share token
        if (game.shareToken !== shareToken) {
            showError('Invalid or expired share link.');
            return;
        }

        // Setup real-time listeners
        setupGameListener(gameId);
        setupBuyInsListener(gameId);
        
        // Load players
        await loadPlayers(game.playerIds || []);

        // Hide loading, show content
        document.getElementById('loading').style.display = 'none';
        document.getElementById('content').style.display = 'block';

    } catch (error) {
        console.error('Error loading game:', error);
        showError('Failed to load game data. Please try again.');
    }
}

// Setup real-time game listener
function setupGameListener(gameId) {
    onSnapshot(doc(db, 'games', gameId), (snapshot) => {
        if (snapshot.exists()) {
            const game = snapshot.data();
            updateGameInfo(game);
        }
    });
}

// Setup real-time buy-ins listener
function setupBuyInsListener(gameId) {
    const buyInsQuery = query(
        collection(db, 'buy_ins'),
        where('gameId', '==', gameId)
    );

    onSnapshot(buyInsQuery, (snapshot) => {
        const buyIns = [];
        snapshot.forEach(doc => {
            buyIns.push({ id: doc.id, ...doc.data() });
        });
        updatePlayerStandings(buyIns);
        updateLastUpdated();
    });
}

// Load player data
async function loadPlayers(playerIds) {
    try {
        for (const playerId of playerIds) {
            const playerDoc = await getDoc(doc(db, 'players', playerId));
            if (playerDoc.exists()) {
                playersCache[playerId] = playerDoc.data();
            }
        }
    } catch (error) {
        console.error('Error loading players:', error);
    }
}

// Update game info display
function updateGameInfo(game) {
    // Game time
    const startTime = game.startTime?.toDate() || new Date();
    const now = new Date();
    const duration = Math.floor((now - startTime) / 1000 / 60);
    const hours = Math.floor(duration / 60);
    const minutes = duration % 60;
    const durationText = hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
    
    document.getElementById('gameTime').textContent = 
        `Started ${startTime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
    document.getElementById('duration').textContent = durationText;
    document.getElementById('playerCount').textContent = (game.playerIds || []).length;
}

// Update player standings
function updatePlayerStandings(buyIns) {
    // Group buy-ins by player
    const playerTotals = {};
    let totalPot = 0;

    buyIns.forEach(buyIn => {
        if (!playerTotals[buyIn.playerId]) {
            playerTotals[buyIn.playerId] = {
                totalBuyIn: 0,
                count: 0
            };
        }
        playerTotals[buyIn.playerId].totalBuyIn += buyIn.amount;
        playerTotals[buyIn.playerId].count++;
        totalPot += buyIn.amount;
    });

    // Update total pot
    document.getElementById('totalPot').textContent = formatCurrency(totalPot);

    // Create player cards
    const playersList = document.getElementById('playersList');
    playersList.innerHTML = '';

    // Sort players by total buy-in (descending)
    const sortedPlayers = Object.entries(playerTotals)
        .sort((a, b) => b[1].totalBuyIn - a[1].totalBuyIn);

    sortedPlayers.forEach(([playerId, data]) => {
        const player = playersCache[playerId] || { name: 'Unknown Player' };
        const card = createPlayerCard(player, data, totalPot);
        playersList.appendChild(card);
    });

    // Show message if no players yet
    if (sortedPlayers.length === 0) {
        playersList.innerHTML = '<p style="text-align: center; color: #94a3b8; padding: 20px;">No players yet. Waiting for game to start...</p>';
    }
}

// Create player card element
function createPlayerCard(player, data, totalPot) {
    const card = document.createElement('div');
    card.className = 'player-card';

    const percentage = totalPot > 0 ? (data.totalBuyIn / totalPot * 100).toFixed(1) : 0;

    card.innerHTML = `
        <div class="player-header">
            <div class="player-name">${escapeHtml(player.name)}</div>
        </div>
        <div class="player-details">
            <div class="player-stat">
                <span>💰 ${formatCurrency(data.totalBuyIn)}</span>
            </div>
            <div class="player-stat">
                <span>${data.count} buy-in${data.count !== 1 ? 's' : ''}</span>
            </div>
            <div class="player-stat">
                <span>${percentage}% of pot</span>
            </div>
        </div>
    `;

    return card;
}

// Format currency
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(amount);
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Update last updated time
function updateLastUpdated() {
    document.getElementById('lastUpdated').textContent = 
        new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
}

// Show error message
function showError(message) {
    document.getElementById('loading').style.display = 'none';
    document.getElementById('content').style.display = 'none';
    const errorDiv = document.getElementById('error');
    errorDiv.textContent = message;
    errorDiv.style.display = 'block';
}

// Start the app
loadGame();
