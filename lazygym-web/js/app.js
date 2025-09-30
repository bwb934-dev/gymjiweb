/**
 * Main App Initialization for LazyGym Web App
 * Initializes the application and handles app-level functionality
 */

class LazyGymApp {
    constructor() {
        this.isInitialized = false;
        this.init();
    }
    
    init() {
        console.log('🚀 Initializing LazyGym Web App...');
        
        // Wait for DOM to be ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.initializeApp());
        } else {
            this.initializeApp();
        }
    }
    
    initializeApp() {
        try {
            // Initialize data manager (already done in dataManager.js)
            console.log('✅ Data Manager initialized');
            
            // Initialize UI manager (already done in ui.js)
            console.log('✅ UI Manager initialized');
            
            // Set up chart event listeners
            this.setupChartListeners();
            
            // Set up keyboard shortcuts
            this.setupKeyboardShortcuts();
            
            // Set up service worker for offline functionality
            this.setupServiceWorker();
            
            // Set up error handling
            this.setupErrorHandling();
            
            // Initial UI update
            window.uiManager.updateUI();
            
            this.isInitialized = true;
            console.log('✅ LazyGym Web App initialized successfully');
            
            // Show welcome message
            this.showWelcomeMessage();
            
        } catch (error) {
            console.error('❌ Failed to initialize LazyGym Web App:', error);
            this.showErrorMessage('Failed to initialize the application. Please refresh the page.');
        }
    }
    
    setupChartListeners() {
        // Exercise selector change
        document.getElementById('exercise-selector').addEventListener('change', () => {
            window.uiManager.updateProgressionChart();
        });
        
        // Metric selector change
        document.getElementById('metric-selector').addEventListener('change', () => {
            window.uiManager.updateProgressionChart();
        });
    }
    
    setupKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            // Only handle shortcuts when not in input fields
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
                return;
            }
            
            switch (e.key) {
                case '1':
                    if (e.ctrlKey || e.metaKey) {
                        e.preventDefault();
                        window.uiManager.switchTab('home');
                    }
                    break;
                case '2':
                    if (e.ctrlKey || e.metaKey) {
                        e.preventDefault();
                        window.uiManager.switchTab('workouts');
                    }
                    break;
                case '3':
                    if (e.ctrlKey || e.metaKey) {
                        e.preventDefault();
                        window.uiManager.switchTab('exercises');
                    }
                    break;
                case '4':
                    if (e.ctrlKey || e.metaKey) {
                        e.preventDefault();
                        window.uiManager.switchTab('history');
                    }
                    break;
                case 's':
                    if (e.ctrlKey || e.metaKey) {
                        e.preventDefault();
                        if (window.dataManager.currentSession) {
                            window.uiManager.startActiveWorkout();
                        } else {
                            window.uiManager.showWorkoutSelectionModal();
                        }
                    }
                    break;
                case 'Escape':
                    // Close modals
                    window.uiManager.closeAllModals();
                    break;
            }
        });
    }
    
    setupServiceWorker() {
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/sw.js')
                .then(registration => {
                    console.log('✅ Service Worker registered:', registration);
                })
                .catch(error => {
                    console.log('⚠️ Service Worker registration failed:', error);
                });
        }
    }
    
    setupErrorHandling() {
        // Global error handler
        window.addEventListener('error', (e) => {
            console.error('Global error:', e.error);
            this.showErrorMessage('An unexpected error occurred. Please try again.');
        });
        
        // Unhandled promise rejection handler
        window.addEventListener('unhandledrejection', (e) => {
            console.error('Unhandled promise rejection:', e.reason);
            this.showErrorMessage('An unexpected error occurred. Please try again.');
        });
    }
    
    showWelcomeMessage() {
        // Show welcome message for first-time users
        const hasSeenWelcome = localStorage.getItem('lazygym_welcome_seen');
        if (!hasSeenWelcome) {
            setTimeout(() => {
                window.uiManager.showNotification('Welcome to LazyGym! Start by adding some exercises or creating your first workout.', 'info');
                localStorage.setItem('lazygym_welcome_seen', 'true');
            }, 1000);
        }
    }
    
    showErrorMessage(message) {
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #FF3B30;
            color: white;
            padding: 20px;
            border-radius: 12px;
            z-index: 10000;
            font-weight: 500;
            text-align: center;
            max-width: 400px;
        `;
        errorDiv.innerHTML = `
            <div style="margin-bottom: 10px;">⚠️</div>
            <div>${message}</div>
            <button onclick="this.parentElement.remove()" style="
                margin-top: 15px;
                background: rgba(255, 255, 255, 0.2);
                border: none;
                color: white;
                padding: 8px 16px;
                border-radius: 6px;
                cursor: pointer;
            ">OK</button>
        `;
        
        document.body.appendChild(errorDiv);
        
        // Auto-remove after 10 seconds
        setTimeout(() => {
            if (errorDiv.parentElement) {
                errorDiv.remove();
            }
        }, 10000);
    }
    
    // Utility methods
    static formatDuration(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const remainingSeconds = seconds % 60;
        
        if (hours > 0) {
            return `${hours}:${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
        } else {
            return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
        }
    }
    
    static formatWeight(weight) {
        return `${weight.toFixed(1)}kg`;
    }
    
    static formatDate(date) {
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        }).format(date);
    }
    
    static formatDateTime(date) {
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(date);
    }
    
    // Export data functionality
    static exportToCSV(data, filename) {
        const csvContent = this.convertToCSV(data);
        const blob = new Blob([csvContent], { type: 'text/csv' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }
    
    static convertToCSV(data) {
        if (data.length === 0) return '';
        
        const headers = Object.keys(data[0]);
        const csvRows = [headers.join(',')];
        
        for (const row of data) {
            const values = headers.map(header => {
                const value = row[header];
                return typeof value === 'string' ? `"${value}"` : value;
            });
            csvRows.push(values.join(','));
        }
        
        return csvRows.join('\n');
    }
    
    // Import data functionality
    static importData(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = (e) => {
                try {
                    const data = JSON.parse(e.target.result);
                    resolve(data);
                } catch (error) {
                    reject(new Error('Invalid JSON file'));
                }
            };
            reader.onerror = () => reject(new Error('Failed to read file'));
            reader.readAsText(file);
        });
    }
    
    // Data validation
    static validateExerciseData(data) {
        const required = ['name', 'progressionType', 'currentWeight'];
        return required.every(field => data.hasOwnProperty(field));
    }
    
    static validateWorkoutData(data) {
        const required = ['name', 'exercises'];
        return required.every(field => data.hasOwnProperty(field)) && Array.isArray(data.exercises);
    }
    
    // Performance monitoring
    static measurePerformance(name, fn) {
        const start = performance.now();
        const result = fn();
        const end = performance.now();
        console.log(`${name} took ${end - start} milliseconds`);
        return result;
    }
    
    // Memory management
    static cleanup() {
        // Clear any timers
        if (window.uiManager) {
            window.uiManager.stopWorkoutTimer();
            if (window.uiManager.restTimer) {
                clearInterval(window.uiManager.restTimer);
            }
        }
        
        // Clear charts
        if (window.progressionChart) {
            window.progressionChart.destroy();
        }
        
        console.log('🧹 App cleanup completed');
    }
}

// Initialize the app
window.lazyGymApp = new LazyGymApp();

// Handle page unload
window.addEventListener('beforeunload', () => {
    LazyGymApp.cleanup();
});

// Handle visibility change (pause timers when tab is hidden)
document.addEventListener('visibilitychange', () => {
    if (window.uiManager && window.dataManager.currentSession) {
        if (document.hidden) {
            // Page is hidden, pause workout timer
            if (!window.uiManager.isWorkoutPaused) {
                window.uiManager.toggleWorkoutPause();
            }
        } else {
            // Page is visible, resume if it was paused due to visibility
            if (window.uiManager.isWorkoutPaused && window.uiManager.pausedTime > 0) {
                window.uiManager.toggleWorkoutPause();
            }
        }
    }
});

// Handle online/offline status
window.addEventListener('online', () => {
    window.uiManager.showNotification('Connection restored', 'success');
});

window.addEventListener('offline', () => {
    window.uiManager.showNotification('You are now offline. Data will be saved locally.', 'warning');
});

// Export utilities to global scope
window.LazyGymUtils = {
    formatDuration: LazyGymApp.formatDuration,
    formatWeight: LazyGymApp.formatWeight,
    formatDate: LazyGymApp.formatDate,
    formatDateTime: LazyGymApp.formatDateTime,
    exportToCSV: LazyGymApp.exportToCSV,
    importData: LazyGymApp.importData,
    validateExerciseData: LazyGymApp.validateExerciseData,
    validateWorkoutData: LazyGymApp.validateWorkoutData
};
