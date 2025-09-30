/**
 * UI Manager for LazyGym Web App
 * Handles all UI interactions and updates
 */

class UIManager {
    constructor() {
        this.currentTab = 'home';
        this.currentAnalyticsTab = 'history';
        this.currentExercise = null;
        this.currentSet = 0;
        this.currentExerciseIndex = 0;
        this.workoutTimer = null;
        this.restTimer = null;
        this.workoutStartTime = null;
        this.isWorkoutPaused = false;
        this.pausedTime = 0;
        
        // Wait for DOM to be ready before initializing
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                this.initializeEventListeners();
                this.updateUI();
            });
        } else {
            this.initializeEventListeners();
            this.updateUI();
        }
    }
    
    // MARK: - Initialization
    initializeEventListeners() {
        try {
            // Tab navigation
            document.querySelectorAll('.nav-tab').forEach(tab => {
                tab.addEventListener('click', (e) => {
                    const tabName = e.currentTarget.dataset.tab;
                    this.switchTab(tabName);
                });
            });
            
            // Analytics tab navigation
            document.querySelectorAll('.analytics-tab').forEach(tab => {
                tab.addEventListener('click', (e) => {
                    const analyticsTab = e.currentTarget.dataset.analytics;
                    this.switchAnalyticsTab(analyticsTab);
                });
            });
            
            // Stat cards navigation
            document.querySelectorAll('.stat-card[data-tab]').forEach(card => {
                card.addEventListener('click', (e) => {
                    const tabName = e.currentTarget.dataset.tab;
                    this.switchTab(tabName);
                });
            });
            
            // Modal controls
            this.initializeModalListeners();
            
            // Form submissions
            this.initializeFormListeners();
            
            // Workout controls
            this.initializeWorkoutListeners();
            
            // Data manager listeners
            if (window.dataManager) {
                window.dataManager.addListener('exercises', () => this.updateUI());
                window.dataManager.addListener('templates', () => this.updateUI());
                window.dataManager.addListener('history', () => this.updateUI());
                window.dataManager.addListener('currentSession', () => this.updateUI());
            }
        } catch (error) {
            console.error('Error initializing event listeners:', error);
        }
    }
    
    initializeModalListeners() {
        try {
            // Modal close buttons
            document.querySelectorAll('.modal-close').forEach(btn => {
                btn.addEventListener('click', () => {
                    this.closeAllModals();
                });
            });
            
            // Modal backgrounds
            document.querySelectorAll('.modal').forEach(modal => {
                modal.addEventListener('click', (e) => {
                    if (e.target === modal) {
                        this.closeAllModals();
                    }
                });
            });
            
            // Start workout button
            const startBtn = document.getElementById('start-workout-btn');
            if (startBtn) {
                startBtn.addEventListener('click', () => {
                    this.showWorkoutSelectionModal();
                });
            }
            
            // Continue workout button
            const continueBtn = document.getElementById('continue-workout-btn');
            if (continueBtn) {
                continueBtn.addEventListener('click', () => {
                    this.startActiveWorkout();
                });
            }
            
            // Add exercise button
            const addExerciseBtn = document.getElementById('add-exercise-btn');
            if (addExerciseBtn) {
                addExerciseBtn.addEventListener('click', () => {
                    this.showAddExerciseModal();
                });
            }
            
            // Add workout button
            const addWorkoutBtn = document.getElementById('add-workout-btn');
            if (addWorkoutBtn) {
                addWorkoutBtn.addEventListener('click', () => {
                    this.showAddWorkoutModal();
                });
            }
            
            // Export data button
            const exportBtn = document.getElementById('export-data-btn');
            if (exportBtn && window.dataManager) {
                exportBtn.addEventListener('click', () => {
                    window.dataManager.exportData();
                });
            }
        } catch (error) {
            console.error('Error initializing modal listeners:', error);
        }
    }
    
    initializeFormListeners() {
        try {
            // Add exercise form
            const exerciseForm = document.getElementById('add-exercise-form');
            if (exerciseForm) {
                exerciseForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    this.handleAddExercise();
                });
            }
            
            // Progression type change
            const progressionType = document.getElementById('progression-type');
            if (progressionType) {
                progressionType.addEventListener('change', (e) => {
                    this.toggleBaseRepsField(e.target.value);
                });
            }
            
            // Add workout form
            const workoutForm = document.getElementById('add-workout-form');
            if (workoutForm) {
                workoutForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    this.handleAddWorkout();
                });
            }
        } catch (error) {
            console.error('Error initializing form listeners:', error);
        }
    }
    
    initializeWorkoutListeners() {
        // Pause/Resume workout
        document.getElementById('pause-workout-btn').addEventListener('click', () => {
            this.toggleWorkoutPause();
        });
        
        // Exit workout
        document.getElementById('exit-workout-btn').addEventListener('click', () => {
            this.exitWorkout();
        });
        
        // Complete set
        document.getElementById('complete-set-btn').addEventListener('click', () => {
            this.completeCurrentSet();
        });
        
        // Skip set
        document.getElementById('skip-set-btn').addEventListener('click', () => {
            this.skipCurrentSet();
        });
        
        // Rest timer controls
        document.getElementById('add-rest-time-btn').addEventListener('click', () => {
            this.addRestTime(30);
        });
        
        document.getElementById('skip-rest-btn').addEventListener('click', () => {
            this.skipRestTimer();
        });
        
        // Close summary
        document.getElementById('close-summary-btn').addEventListener('click', () => {
            this.closeWorkoutSummary();
        });
    }
    
    // MARK: - Tab Management
    switchTab(tabName) {
        // Update navigation
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.classList.remove('active');
        });
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
        
        // Update content
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.remove('active');
        });
        document.getElementById(`${tabName}-tab`).classList.add('active');
        
        this.currentTab = tabName;
        this.updateUI();
    }
    
    switchAnalyticsTab(analyticsTab) {
        // Update analytics navigation
        document.querySelectorAll('.analytics-tab').forEach(tab => {
            tab.classList.remove('active');
        });
        document.querySelector(`[data-analytics="${analyticsTab}"]`).classList.add('active');
        
        // Update analytics content
        document.querySelectorAll('.analytics-content').forEach(content => {
            content.classList.remove('active');
        });
        document.getElementById(`${analyticsTab}-content`).classList.add('active');
        
        this.currentAnalyticsTab = analyticsTab;
        
        if (analyticsTab === 'analytics') {
            this.updateAnalytics();
        }
    }
    
    // MARK: - Modal Management
    showModal(modalId) {
        document.getElementById(modalId).classList.add('active');
    }
    
    closeModal(modalId) {
        document.getElementById(modalId).classList.remove('active');
    }
    
    closeAllModals() {
        document.querySelectorAll('.modal').forEach(modal => {
            modal.classList.remove('active');
        });
    }
    
    showAddExerciseModal() {
        // Reset form
        document.getElementById('add-exercise-form').reset();
        this.toggleBaseRepsField(document.getElementById('progression-type').value);
        this.showModal('add-exercise-modal');
    }
    
    showAddWorkoutModal() {
        // Populate exercise selection
        this.populateExerciseSelection();
        this.showModal('add-workout-modal');
    }
    
    showWorkoutSelectionModal() {
        this.populateWorkoutSelection();
        this.showModal('workout-selection-modal');
    }
    
    // MARK: - Form Handlers
    handleAddExercise() {
        const formData = new FormData(document.getElementById('add-exercise-form'));
        const exercise = new window.LazyGymModels.Exercise(
            formData.get('exercise-name') || document.getElementById('exercise-name').value,
            document.getElementById('progression-type').value,
            document.getElementById('body-part').value === 'upper',
            parseFloat(document.getElementById('current-weight').value) || 0,
            parseInt(document.getElementById('base-reps').value) || 10,
            document.getElementById('body-part').value
        );
        
        window.dataManager.addExercise(exercise);
        this.closeModal('add-exercise-modal');
        this.showNotification('Exercise added successfully!', 'success');
    }
    
    handleAddWorkout() {
        const name = document.getElementById('workout-name').value;
        const focus = document.getElementById('workout-focus').value;
        
        // Get selected exercises
        const selectedExercises = [];
        document.querySelectorAll('#exercise-selection input[type="checkbox"]:checked').forEach(checkbox => {
            const exerciseId = checkbox.value;
            const exercise = window.dataManager.exercises.find(e => e.id === exerciseId);
            if (exercise) {
                selectedExercises.push(exercise);
            }
        });
        
        if (selectedExercises.length === 0) {
            this.showNotification('Please select at least one exercise', 'error');
            return;
        }
        
        const template = new window.LazyGymModels.WorkoutTemplate(
            name,
            selectedExercises,
            [],
            focus
        );
        
        window.dataManager.addWorkoutTemplate(template);
        this.closeModal('add-workout-modal');
        this.showNotification('Workout created successfully!', 'success');
    }
    
    toggleBaseRepsField(progressionType) {
        const baseRepsGroup = document.getElementById('base-reps-group');
        if (progressionType === 'pyramid') {
            baseRepsGroup.style.display = 'block';
        } else {
            baseRepsGroup.style.display = 'none';
        }
    }
    
    populateExerciseSelection() {
        const container = document.getElementById('exercise-selection');
        container.innerHTML = '';
        
        window.dataManager.exercises.forEach(exercise => {
            const div = document.createElement('div');
            div.className = 'exercise-checkbox';
            div.innerHTML = `
                <input type="checkbox" id="exercise-${exercise.id}" value="${exercise.id}">
                <label for="exercise-${exercise.id}">
                    <strong>${exercise.name}</strong>
                    <span class="tag ${exercise.progressionType}">${window.LazyGymModels.ProgressionType.getDisplayName(exercise.progressionType)}</span>
                </label>
            `;
            container.appendChild(div);
        });
    }
    
    populateWorkoutSelection() {
        const container = document.getElementById('workout-selection-list');
        const noWorkouts = document.getElementById('no-workouts-selection');
        
        if (window.dataManager.workoutTemplates.length === 0) {
            container.style.display = 'none';
            noWorkouts.style.display = 'block';
            return;
        }
        
        container.style.display = 'block';
        noWorkouts.style.display = 'none';
        container.innerHTML = '';
        
        window.dataManager.workoutTemplates.forEach(template => {
            const div = document.createElement('div');
            div.className = 'workout-selection-item';
            div.innerHTML = `
                <div class="workout-selection-header">
                    <div class="workout-selection-name">${template.name}</div>
                    <button class="btn btn-primary" onclick="uiManager.startWorkoutWithTemplate('${template.id}')">Start</button>
                </div>
                <div class="workout-selection-meta">${template.currentExercises.length} exercises</div>
                <div class="item-tags">
                    ${template.currentExercises.slice(0, 3).map(exercise => 
                        `<span class="tag">${exercise.exercise.name}</span>`
                    ).join('')}
                    ${template.currentExercises.length > 3 ? `<span class="tag">+${template.currentExercises.length - 3} more</span>` : ''}
                </div>
            `;
            container.appendChild(div);
        });
    }
    
    startWorkoutWithTemplate(templateId) {
        const template = window.dataManager.workoutTemplates.find(t => t.id === templateId);
        if (template) {
            window.dataManager.startWorkout(template);
            this.closeModal('workout-selection-modal');
            this.startActiveWorkout();
        }
    }
    
    // MARK: - Active Workout
    startActiveWorkout() {
        if (!window.dataManager.currentSession) return;
        
        this.currentExerciseIndex = 0;
        this.currentSet = 0;
        this.workoutStartTime = new Date();
        this.isWorkoutPaused = false;
        this.pausedTime = 0;
        
        this.updateActiveWorkoutUI();
        this.startWorkoutTimer();
        this.showModal('active-workout-modal');
    }
    
    updateActiveWorkoutUI() {
        const session = window.dataManager.currentSession;
        if (!session) return;
        
        // Migrate template to new format if needed
        session.template.migrateToNewFormat();
        
        const exerciseInstance = session.template.exerciseInstances[this.currentExerciseIndex];
        if (!exerciseInstance) return;
        
        const set = exerciseInstance.sets[this.currentSet];
        if (!set) return;
        
        // Update exercise info
        const exerciseInfo = document.getElementById('workout-exercise-info');
        exerciseInfo.innerHTML = `
            <div class="exercise-name">${exerciseInstance.exercise.name}</div>
            <div class="set-info">
                <div>Set ${this.currentSet + 1} of ${exerciseInstance.sets.length}</div>
            </div>
        `;
        
        // Update set info
        const setInfo = document.getElementById('workout-set-info');
        setInfo.innerHTML = `
            <div class="weight-display">${set.weight}kg</div>
            <div class="planned-reps">${set.plannedReps === 0 ? 'To Failure' : set.plannedReps + ' reps'}</div>
            <div class="form-group">
                <label>Actual Reps</label>
                <input type="number" id="actual-reps-input" class="form-input" value="${set.plannedReps || 0}" min="0">
            </div>
        `;
        
        // Update button states
        const isLastSet = this.currentSet >= exerciseInstance.sets.length - 1;
        const isLastExercise = this.currentExerciseIndex >= session.template.exerciseInstances.length - 1;
        
        document.getElementById('skip-set-btn').style.display = (isLastSet && isLastExercise) ? 'none' : 'block';
    }
    
    completeCurrentSet() {
        const actualReps = parseInt(document.getElementById('actual-reps-input').value) || 0;
        const session = window.dataManager.currentSession;
        
        if (!session) return;
        
        const exerciseInstance = session.template.exerciseInstances[this.currentExerciseIndex];
        const set = exerciseInstance.sets[this.currentSet];
        
        // Complete the set
        set.complete(actualReps);
        
        // Check if exercise is completed
        const allSetsCompleted = exerciseInstance.sets.every(s => s.isCompleted);
        if (allSetsCompleted) {
            exerciseInstance.isCompleted = true;
        }
        
        this.nextSet();
    }
    
    skipCurrentSet() {
        this.nextSet();
    }
    
    nextSet() {
        const session = window.dataManager.currentSession;
        if (!session) return;
        
        const exerciseInstance = session.template.exerciseInstances[this.currentExerciseIndex];
        const isLastSet = this.currentSet >= exerciseInstance.sets.length - 1;
        const isLastExercise = this.currentExerciseIndex >= session.template.exerciseInstances.length - 1;
        
        if (isLastSet) {
            if (isLastExercise) {
                // Workout complete
                this.completeWorkout();
                return;
            } else {
                // Move to next exercise
                this.currentExerciseIndex++;
                this.currentSet = 0;
            }
        } else {
            // Move to next set
            this.currentSet++;
        }
        
        // Show rest timer if not the last set of the last exercise
        if (!(isLastSet && isLastExercise)) {
            this.showRestTimer();
        } else {
            this.updateActiveWorkoutUI();
        }
    }
    
    completeWorkout() {
        this.stopWorkoutTimer();
        window.dataManager.endWorkout();
        this.closeModal('active-workout-modal');
        this.showWorkoutSummary();
    }
    
    showWorkoutSummary() {
        const session = window.dataManager.workoutHistory[window.dataManager.workoutHistory.length - 1];
        if (!session) return;
        
        const summaryContent = document.getElementById('workout-summary-content');
        summaryContent.innerHTML = `
            <div class="workout-summary">
                <h3>Great job! 🎉</h3>
                <p>Workout completed in ${session.getFormattedDuration()}</p>
                <div class="summary-stats">
                    <div class="stat-item">
                        <span class="stat-label">Exercises</span>
                        <span class="stat-value">${session.template.exerciseInstances.length}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">Sets Completed</span>
                        <span class="stat-value">${session.template.exerciseInstances.reduce((total, exercise) => 
                            total + exercise.sets.filter(set => set.isCompleted).length, 0)}</span>
                    </div>
                </div>
            </div>
        `;
        
        this.showModal('workout-summary-modal');
    }
    
    closeWorkoutSummary() {
        this.closeModal('workout-summary-modal');
    }
    
    // MARK: - Timer Management
    startWorkoutTimer() {
        this.workoutTimer = setInterval(() => {
            if (!this.isWorkoutPaused) {
                const elapsed = new Date() - this.workoutStartTime - this.pausedTime;
                const minutes = Math.floor(elapsed / 60000);
                const seconds = Math.floor((elapsed % 60000) / 1000);
                document.getElementById('workout-timer').textContent = 
                    `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
            }
        }, 1000);
    }
    
    stopWorkoutTimer() {
        if (this.workoutTimer) {
            clearInterval(this.workoutTimer);
            this.workoutTimer = null;
        }
    }
    
    toggleWorkoutPause() {
        this.isWorkoutPaused = !this.isWorkoutPaused;
        const btn = document.getElementById('pause-workout-btn');
        
        if (this.isWorkoutPaused) {
            btn.textContent = '▶️';
            this.pausedTime += new Date() - this.workoutStartTime;
        } else {
            btn.textContent = '⏸️';
            this.workoutStartTime = new Date();
        }
    }
    
    exitWorkout() {
        if (confirm('Are you sure you want to exit this workout? Your progress will be saved.')) {
            this.stopWorkoutTimer();
            window.dataManager.endWorkout();
            this.closeModal('active-workout-modal');
            this.showNotification('Workout saved', 'info');
        }
    }
    
    // MARK: - Rest Timer
    showRestTimer() {
        this.restTimeRemaining = 90; // 1:30 default
        this.updateRestTimer();
        this.showModal('rest-timer-modal');
        this.startRestTimer();
    }
    
    startRestTimer() {
        this.restTimer = setInterval(() => {
            this.restTimeRemaining--;
            this.updateRestTimer();
            
            if (this.restTimeRemaining <= 0) {
                this.skipRestTimer();
            }
        }, 1000);
    }
    
    updateRestTimer() {
        const minutes = Math.floor(this.restTimeRemaining / 60);
        const seconds = this.restTimeRemaining % 60;
        document.getElementById('rest-timer').textContent = 
            `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
        
        // Update progress ring
        const progress = (90 - this.restTimeRemaining) / 90;
        const circumference = 2 * Math.PI * 54; // radius = 54
        const strokeDashoffset = circumference - (progress * circumference);
        
        const progressCircle = document.querySelector('.progress-ring-circle:last-child');
        if (progressCircle) {
            progressCircle.style.strokeDashoffset = strokeDashoffset;
        }
    }
    
    addRestTime(seconds) {
        this.restTimeRemaining += seconds;
        this.updateRestTimer();
    }
    
    skipRestTimer() {
        if (this.restTimer) {
            clearInterval(this.restTimer);
            this.restTimer = null;
        }
        this.closeModal('rest-timer-modal');
        this.updateActiveWorkoutUI();
    }
    
    // MARK: - UI Updates
    updateUI() {
        try {
            this.updateStats();
            this.updateCurrentSession();
            
            switch (this.currentTab) {
                case 'workouts':
                    this.updateWorkoutsList();
                    break;
                case 'exercises':
                    this.updateExercisesList();
                    break;
                case 'history':
                    if (this.currentAnalyticsTab === 'history') {
                        this.updateHistoryList();
                    } else {
                        this.updateAnalytics();
                    }
                    break;
            }
        } catch (error) {
            console.error('Error updating UI:', error);
        }
    }
    
    updateStats() {
        try {
            if (window.dataManager) {
                const exerciseCount = document.getElementById('exercise-count');
                const workoutCount = document.getElementById('workout-count');
                const sessionCount = document.getElementById('session-count');
                
                if (exerciseCount) exerciseCount.textContent = window.dataManager.exercises.length;
                if (workoutCount) workoutCount.textContent = window.dataManager.workoutTemplates.length;
                if (sessionCount) sessionCount.textContent = window.dataManager.workoutHistory.length;
            }
        } catch (error) {
            console.error('Error updating stats:', error);
        }
    }
    
    updateCurrentSession() {
        const currentSessionCard = document.getElementById('current-session-card');
        const sessionName = document.getElementById('current-session-name');
        
        if (window.dataManager.currentSession) {
            currentSessionCard.style.display = 'block';
            sessionName.textContent = window.dataManager.currentSession.template.name;
        } else {
            currentSessionCard.style.display = 'none';
        }
    }
    
    updateWorkoutsList() {
        const container = document.getElementById('workouts-list');
        const noWorkouts = document.getElementById('no-workouts');
        
        if (window.dataManager.workoutTemplates.length === 0) {
            container.style.display = 'none';
            noWorkouts.style.display = 'block';
            return;
        }
        
        container.style.display = 'block';
        noWorkouts.style.display = 'none';
        container.innerHTML = '';
        
        window.dataManager.workoutTemplates.forEach(template => {
            const div = document.createElement('div');
            div.className = 'workout-item';
            div.innerHTML = `
                <div class="item-header">
                    <div class="item-title">${template.name}</div>
                    <div class="item-actions">
                        <button class="btn btn-secondary" onclick="uiManager.editWorkout('${template.id}')">Edit</button>
                        <button class="btn btn-primary" onclick="uiManager.startWorkoutWithTemplate('${template.id}')">Start</button>
                    </div>
                </div>
                <div class="item-meta">${template.currentExercises.length} exercises</div>
                <div class="item-tags">
                    ${template.currentExercises.slice(0, 3).map(exercise => 
                        `<span class="tag">${exercise.exercise.name}</span>`
                    ).join('')}
                    ${template.currentExercises.length > 3 ? `<span class="tag">+${template.currentExercises.length - 3} more</span>` : ''}
                </div>
            `;
            container.appendChild(div);
        });
    }
    
    updateExercisesList() {
        const container = document.getElementById('exercises-list');
        container.innerHTML = '';
        
        window.dataManager.exercises.forEach(exercise => {
            const div = document.createElement('div');
            div.className = 'exercise-item';
            div.innerHTML = `
                <div class="item-header">
                    <div class="item-title">${exercise.name}</div>
                    <div class="item-actions">
                        <button class="btn btn-secondary" onclick="uiManager.editExercise('${exercise.id}')">Edit</button>
                    </div>
                </div>
                <div class="item-meta">
                    <span class="tag ${exercise.progressionType}">${window.LazyGymModels.ProgressionType.getDisplayName(exercise.progressionType)}</span>
                    <span>${exercise.bodyPart === 'upper' ? 'Upper Body' : exercise.bodyPart === 'lower' ? 'Lower Body' : 'Full Body'}</span>
                </div>
                <div class="item-meta">
                    ${exercise.currentWeight > 0 ? `Current Weight: ${exercise.currentWeight}kg` : ''}
                    ${exercise.progressionType === 'pyramid' ? `Base Reps: ${exercise.baseReps}` : ''}
                </div>
            `;
            container.appendChild(div);
        });
    }
    
    updateHistoryList() {
        const container = document.getElementById('workout-history-list');
        const noHistory = document.getElementById('no-history');
        
        if (window.dataManager.workoutHistory.length === 0) {
            container.style.display = 'none';
            noHistory.style.display = 'block';
            return;
        }
        
        container.style.display = 'block';
        noHistory.style.display = 'none';
        container.innerHTML = '';
        
        const sortedHistory = [...window.dataManager.workoutHistory].sort((a, b) => 
            b.startTime.getTime() - a.startTime.getTime()
        );
        
        sortedHistory.forEach(session => {
            const div = document.createElement('div');
            div.className = 'history-item';
            div.innerHTML = `
                <div class="item-header">
                    <div class="item-title">${session.template.name}</div>
                    <div class="item-meta">${session.startTime.toLocaleDateString()}</div>
                </div>
                <div class="item-meta">
                    ${session.template.exerciseInstances.length} exercises • ${session.getFormattedDuration()}
                </div>
                <div class="item-meta">
                    Progress: ${session.template.exerciseInstances.filter(ex => ex.isCompleted).length}/${session.template.exerciseInstances.length}
                </div>
            `;
            container.appendChild(div);
        });
    }
    
    updateAnalytics() {
        const stats = window.dataManager.calculateWorkoutStats();
        
        document.getElementById('total-workouts').textContent = stats.totalWorkouts;
        document.getElementById('avg-per-week').textContent = stats.averageWorkoutsPerWeek.toFixed(1);
        document.getElementById('heaviest-lift').textContent = stats.heaviestLift.toFixed(1) + 'kg';
        document.getElementById('longest-streak').textContent = stats.longestStreak + ' days';
        
        // Update exercise selector
        const exerciseSelector = document.getElementById('exercise-selector');
        exerciseSelector.innerHTML = '<option value="">Select Exercise</option>';
        window.dataManager.exercises.forEach(exercise => {
            const option = document.createElement('option');
            option.value = exercise.id;
            option.textContent = exercise.name;
            exerciseSelector.appendChild(option);
        });
        
        // Update progression chart
        this.updateProgressionChart();
    }
    
    updateProgressionChart() {
        const exerciseId = document.getElementById('exercise-selector').value;
        const metric = document.getElementById('metric-selector').value;
        
        if (!exerciseId) return;
        
        const exercise = window.dataManager.exercises.find(e => e.id === exerciseId);
        if (!exercise) return;
        
        const dataPoints = window.dataManager.calculateExerciseProgression(
            exercise, 
            metric, 
            window.LazyGymModels.Timeframe.TWELVE_WEEKS
        );
        
        this.renderProgressionChart(dataPoints, metric);
    }
    
    renderProgressionChart(dataPoints, metric) {
        const ctx = document.getElementById('progression-chart').getContext('2d');
        
        if (window.progressionChart) {
            window.progressionChart.destroy();
        }
        
        window.progressionChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: dataPoints.map(point => point.date.toLocaleDateString()),
                datasets: [{
                    label: window.LazyGymModels.AnalyticsMetric.getDisplayName(metric),
                    data: dataPoints.map(point => point.value),
                    borderColor: '#007AFF',
                    backgroundColor: 'rgba(0, 122, 255, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
    
    // MARK: - Utility
    showNotification(message, type = 'info') {
        // Simple notification system
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'success' ? '#34C759' : type === 'error' ? '#FF3B30' : '#007AFF'};
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            z-index: 10000;
            font-weight: 500;
        `;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }
    
    editExercise(exerciseId) {
        // TODO: Implement exercise editing
        this.showNotification('Exercise editing coming soon!', 'info');
    }
    
    editWorkout(templateId) {
        // TODO: Implement workout editing
        this.showNotification('Workout editing coming soon!', 'info');
    }
}

// Initialize UI Manager
window.uiManager = new UIManager();
