/**
 * Data Manager for LazyGym Web App
 * Replicates the SwiftUI app's data management functionality
 */

const { 
    Exercise, 
    WorkoutTemplate, 
    WorkoutSession, 
    ProgressionType, 
    WorkoutFocus,
    WorkoutStats,
    WeeklyWorkoutData,
    ProgressionDataPoint,
    AnalyticsMetric,
    Timeframe
} = window.LazyGymModels;

class DataManager {
    constructor() {
        this.exercises = [];
        this.workoutTemplates = [];
        this.workoutHistory = [];
        this.currentSession = null;
        
        // Storage keys
        this.exercisesKey = 'lazygym_exercises';
        this.templatesKey = 'lazygym_templates';
        this.historyKey = 'lazygym_history';
        
        this.loadData();
        this.reloadDefaultExercises();
    }
    
    // MARK: - Data Persistence
    loadData() {
        this.loadExercises();
        this.loadWorkoutTemplates();
        this.loadWorkoutHistory();
    }
    
    saveData() {
        this.saveExercises();
        this.saveWorkoutTemplates();
        this.saveWorkoutHistory();
    }
    
    // MARK: - Exercise Management
    addExercise(exercise) {
        this.exercises.push(exercise);
        this.saveExercises();
        this.notifyListeners('exercises');
    }
    
    updateExercise(exercise) {
        const index = this.exercises.findIndex(e => e.id === exercise.id);
        if (index !== -1) {
            this.exercises[index] = exercise;
            this.saveExercises();
            this.notifyListeners('exercises');
        }
    }
    
    deleteExercise(exercise) {
        this.exercises = this.exercises.filter(e => e.id !== exercise.id);
        this.saveExercises();
        this.notifyListeners('exercises');
    }
    
    resetToDefaultExercises() {
        this.exercises = [];
        this.addDefaultExercises();
    }
    
    clearAllExercises() {
        this.exercises = [];
        this.saveExercises();
        console.log('   - Cleared all exercises');
        this.notifyListeners('exercises');
    }
    
    reloadDefaultExercises() {
        console.log('🔄 Reloading default exercises...');
        this.exercises = [];
        this.addDefaultExercises();
        console.log('✅ Default exercises reloaded');
        this.notifyListeners('exercises');
    }
    
    removeDuplicateExercises() {
        const uniqueExercises = [];
        const seenNames = new Set();
        
        for (const exercise of this.exercises) {
            if (!seenNames.has(exercise.name)) {
                uniqueExercises.push(exercise);
                seenNames.add(exercise.name);
            }
        }
        
        const removedCount = this.exercises.length - uniqueExercises.length;
        this.exercises = uniqueExercises;
        this.saveExercises();
        console.log('   - Removed', removedCount, 'duplicate exercises');
        this.notifyListeners('exercises');
    }
    
    loadExercises() {
        console.log('🔍 DataManager.loadExercises called');
        try {
            const data = localStorage.getItem(this.exercisesKey);
            if (data) {
                const parsed = JSON.parse(data);
                this.exercises = parsed.map(exerciseData => Exercise.fromJSON(exerciseData));
                console.log('   - Loaded', this.exercises.length, 'exercises:');
                this.exercises.forEach(exercise => {
                    console.log('   -', exercise.name + ':', 'currentReps =', exercise.currentReps || []);
                });
                
                // Remove duplicates if any exist
                const originalCount = this.exercises.length;
                this.removeDuplicateExercises();
                if (originalCount !== this.exercises.length) {
                    console.log('   - Found and removed duplicate exercises');
                }
            } else {
                console.log('   - No exercises found in localStorage, adding defaults');
                this.addDefaultExercises();
            }
        } catch (error) {
            console.error('Error loading exercises:', error);
            this.addDefaultExercises();
        }
    }
    
    addDefaultExercises() {
        // Only add default exercises if none exist
        if (this.exercises.length === 0) {
            const defaultExercises = [
                new Exercise('Squat', ProgressionType.AMRAP, false, 60.0),
                new Exercise('Deadlift', ProgressionType.AMRAP, false, 80.0),
                new Exercise('Pull up', ProgressionType.PYRAMID, true, 0.0, 8),
                new Exercise('Push-up', ProgressionType.AMRAP, true, 20.0),
                new Exercise('Kettlebell swing', ProgressionType.PYRAMID, false, 24.0, 15),
                new Exercise('Overhead Press', ProgressionType.AMRAP, true, 20.0)
            ];
            
            this.exercises = defaultExercises;
            this.saveExercises();
            console.log('   - Added', defaultExercises.length, 'default exercises');
        } else {
            console.log('   - Exercises already exist, skipping default creation');
        }
    }
    
    saveExercises() {
        try {
            const data = JSON.stringify(this.exercises.map(exercise => exercise.toJSON()));
            localStorage.setItem(this.exercisesKey, data);
            console.log('✅ Successfully saved', this.exercises.length, 'exercises');
        } catch (error) {
            console.error('❌ Error saving exercises:', error);
        }
    }
    
    // MARK: - Workout Template Management
    addWorkoutTemplate(template) {
        // Migrate template to new format if needed
        template.migrateToNewFormat();
        this.workoutTemplates.push(template);
        this.saveWorkoutTemplates();
        this.notifyListeners('templates');
    }
    
    updateWorkoutTemplate(template) {
        const index = this.workoutTemplates.findIndex(t => t.id === template.id);
        if (index !== -1) {
            this.workoutTemplates[index] = template;
            this.saveWorkoutTemplates();
            this.notifyListeners('templates');
        }
    }
    
    deleteWorkoutTemplate(template) {
        this.workoutTemplates = this.workoutTemplates.filter(t => t.id !== template.id);
        this.saveWorkoutTemplates();
        this.notifyListeners('templates');
    }
    
    loadWorkoutTemplates() {
        try {
            const data = localStorage.getItem(this.templatesKey);
            if (data) {
                const parsed = JSON.parse(data);
                this.workoutTemplates = parsed.map(templateData => WorkoutTemplate.fromJSON(templateData));
                console.log('🔍 Loaded workout templates:');
                this.workoutTemplates.forEach(template => {
                    console.log('   -', template.name + ':', template.exercises.length, 'exercises');
                });
                
                // Check if all templates have 0 exercises and reset if needed
                const allEmpty = this.workoutTemplates.every(template => template.exercises.length === 0);
                if (allEmpty && this.workoutTemplates.length > 0) {
                    console.log('🔍 All existing templates are empty, clearing and creating defaults...');
                    this.workoutTemplates = [];
                    this.addDefaultWorkoutTemplates();
                }
            } else {
                // Add default workout templates if none exist
                console.log('🔍 No existing workout templates found, creating defaults...');
                this.addDefaultWorkoutTemplates();
            }
        } catch (error) {
            console.error('Error loading workout templates:', error);
            this.addDefaultWorkoutTemplates();
        }
    }
    
    addDefaultWorkoutTemplates() {
        // Create a default workout template using existing exercises
        console.log('🔍 Creating default workout templates...');
        console.log('   - Available exercises:', this.exercises.map(e => e.name));
        
        const pushUpExercise = this.exercises.find(e => e.name === 'Push-up');
        const squatExercise = this.exercises.find(e => e.name === 'Squat');
        const deadliftExercise = this.exercises.find(e => e.name === 'Deadlift');
        
        const workoutExercises = [];
        
        if (pushUpExercise) {
            workoutExercises.push(pushUpExercise);
            console.log('   - Added Push-up exercise');
        }
        if (squatExercise) {
            workoutExercises.push(squatExercise);
            console.log('   - Added Squat exercise');
        }
        if (deadliftExercise) {
            workoutExercises.push(deadliftExercise);
            console.log('   - Added Deadlift exercise');
        }
        
        if (workoutExercises.length > 0) {
            const defaultTemplate = new WorkoutTemplate(
                'Full Body Workout',
                workoutExercises,
                [],
                WorkoutFocus.FULL
            );
            
            this.workoutTemplates = [defaultTemplate];
            this.saveWorkoutTemplates();
            console.log('   - Created default template with', workoutExercises.length, 'exercises');
        } else {
            console.log('   - ❌ No exercises found to create default template');
        }
    }
    
    saveWorkoutTemplates() {
        try {
            const data = JSON.stringify(this.workoutTemplates.map(template => template.toJSON()));
            localStorage.setItem(this.templatesKey, data);
            console.log('✅ Successfully saved', this.workoutTemplates.length, 'workout templates');
        } catch (error) {
            console.error('❌ Error saving workout templates:', error);
        }
    }
    
    // MARK: - Workout History Management
    addWorkoutSession(session) {
        this.workoutHistory.push(session);
        this.saveWorkoutHistory();
        this.notifyListeners('history');
    }
    
    updateWorkoutSession(session) {
        const index = this.workoutHistory.findIndex(s => s.id === session.id);
        if (index !== -1) {
            this.workoutHistory[index] = session;
            this.saveWorkoutHistory();
            this.notifyListeners('history');
        }
    }
    
    loadWorkoutHistory() {
        console.log('🔍 DataManager.loadWorkoutHistory called');
        try {
            const data = localStorage.getItem(this.historyKey);
            if (data) {
                const parsed = JSON.parse(data);
                this.workoutHistory = parsed.map(sessionData => WorkoutSession.fromJSON(sessionData));
                console.log('   - Loaded', this.workoutHistory.length, 'workout sessions');
                this.workoutHistory.forEach((session, index) => {
                    console.log('   - Session', index + ':', session.template.name, '-', session.startTime);
                });
            } else {
                console.log('   - No workout history found in localStorage');
                this.workoutHistory = [];
            }
        } catch (error) {
            console.error('Error loading workout history:', error);
            this.workoutHistory = [];
        }
    }
    
    saveWorkoutHistory() {
        try {
            const data = JSON.stringify(this.workoutHistory.map(session => session.toJSON()));
            localStorage.setItem(this.historyKey, data);
            console.log('✅ Successfully saved', this.workoutHistory.length, 'workout sessions');
        } catch (error) {
            console.error('❌ Error saving workout history:', error);
        }
    }
    
    // MARK: - Current Session Management
    startWorkout(template) {
        const session = new WorkoutSession(template);
        this.currentSession = session;
        this.notifyListeners('currentSession');
    }
    
    endWorkout() {
        if (!this.currentSession) return;
        
        this.currentSession.complete();
        
        // Apply progression updates to exercises
        this.applyProgressionUpdates(this.currentSession);
        
        this.addWorkoutSession(this.currentSession);
        this.currentSession = null;
        this.notifyListeners('currentSession');
    }
    
    applyProgressionUpdates(session) {
        console.log('🔄 Starting progression updates...');
        
        // Migrate template to new format if needed
        session.template.migrateToNewFormat();
        
        console.log('📊 Template has', session.template.exerciseInstances.length, 'exercise instances');
        console.log('📊 DataManager has', this.exercises.length, 'exercises');
        
        // Update progression for each exercise instance
        for (let exerciseIndex = 0; exerciseIndex < session.template.exerciseInstances.length; exerciseIndex++) {
            const instance = session.template.exerciseInstances[exerciseIndex];
            const completedSets = instance.sets.filter(set => set.isCompleted);
            
            console.log('🏋️ Exercise:', instance.exercise.name);
            console.log('   - Exercise ID:', instance.exercise.id);
            console.log('   - Progression Type:', instance.effectiveProgressionType);
            console.log('   - Completed Sets:', completedSets.length);
            console.log('   - Total Sets:', instance.sets.length);
            
            if (completedSets.length > 0) {
                console.log('   - Final Set Reps:', completedSets[completedSets.length - 1].actualReps || 0);
                
                // Find the base exercise in our exercise list and update it
                // Use name matching as a fallback since IDs might not match due to copying
                const baseExerciseIndex = this.exercises.findIndex(e => e.name === instance.exercise.name);
                if (baseExerciseIndex !== -1) {
                    const baseExercise = this.exercises[baseExerciseIndex];
                    const oldWeight = baseExercise.currentWeight;
                    
                    console.log('   - Base Exercise Found:', baseExercise.name);
                    console.log('   - Base Exercise ID:', baseExercise.id);
                    console.log('   - Current Weight:', oldWeight + 'kg');
                    
                    // Apply progression based on the instance's effective progression type
                    switch (instance.effectiveProgressionType) {
                        case ProgressionType.AMRAP:
                            const finalSet = completedSets[completedSets.length - 1];
                            if (finalSet && finalSet.actualReps !== null) {
                                const newWeight = window.ProgressionCalculator.calculateAMRAPProgression(
                                    baseExercise, 
                                    finalSet.actualReps, 
                                    session.template.focus
                                );
                                baseExercise.currentWeight = newWeight;
                                console.log('   - AMRAP Progression:', oldWeight + 'kg →', newWeight + 'kg (final set:', finalSet.actualReps, 'reps)');
                            } else {
                                console.log('   - ❌ No final set or actual reps found');
                            }
                            break;
                        case ProgressionType.PYRAMID:
                            const newCurrentReps = window.ProgressionCalculator.calculatePyramidProgression(
                                baseExercise, 
                                completedSets
                            );
                            baseExercise.currentReps = newCurrentReps;
                            console.log('   - Pyramid Progression: current reps updated to', newCurrentReps);
                            break;
                        case ProgressionType.FREE:
                            // Free progression: No automatic weight progression, just update last workout date
                            console.log('   - Free Progression: No weight change (Free progression doesn\'t auto-increment)');
                            break;
                    }
                    
                    baseExercise.lastWorkoutDate = new Date();
                    this.exercises[baseExerciseIndex] = baseExercise;
                    console.log('   - ✅ Base exercise updated');
                } else {
                    console.log('   - ❌ Base exercise NOT found in DataManager');
                    console.log('   - Available exercise names:', this.exercises.map(e => e.name));
                }
            } else {
                console.log('   - ⚠️ No completed sets found');
            }
        }
        
        // Save the updated exercises
        this.saveExercises();
        console.log('💾 Progression updates saved');
    }
    
    // MARK: - Set Weight Updates
    updateSetWeight(exerciseId, setIndex, newWeight) {
        if (!this.currentSession) return;
        
        // Migrate template to new format if needed
        this.currentSession.template.migrateToNewFormat();
        
        // Find the exercise in the current session using exerciseInstances
        for (let exerciseIndex = 0; exerciseIndex < this.currentSession.template.exerciseInstances.length; exerciseIndex++) {
            const instance = this.currentSession.template.exerciseInstances[exerciseIndex];
            if (instance.exercise.id === exerciseId && setIndex < instance.sets.length) {
                // Update the weight in the set
                instance.sets[setIndex].weight = newWeight;
                console.log('🏋️ Updated weight for', instance.exercise.name, 'Set', setIndex + 1, 'to', newWeight + 'kg');
                break;
            }
        }
    }
    
    // MARK: - Analytics
    calculateWorkoutStats() {
        console.log('📊 WorkoutStatsCalculator.calculate called with', this.workoutHistory.length, 'workouts');
        
        const totalWorkouts = this.workoutHistory.length;
        
        // Calculate average workouts per week
        const now = new Date();
        const twelveWeeksAgo = new Date(now.getTime() - (12 * 7 * 24 * 60 * 60 * 1000));
        
        const recentWorkouts = this.workoutHistory.filter(session => 
            session.startTime >= twelveWeeksAgo
        );
        const weeks = Math.max(1, Math.ceil((now - twelveWeeksAgo) / (7 * 24 * 60 * 60 * 1000)));
        const averageWorkoutsPerWeek = recentWorkouts.length / weeks;
        
        console.log('   - Recent workouts:', recentWorkouts.length);
        console.log('   - Weeks:', weeks);
        console.log('   - Average per week:', averageWorkoutsPerWeek);
        
        // Calculate heaviest lift
        let heaviestLift = 0;
        this.workoutHistory.forEach(session => {
            session.template.exerciseInstances.forEach(instance => {
                instance.sets.forEach(set => {
                    if (set.weight > heaviestLift) {
                        heaviestLift = set.weight;
                    }
                });
            });
        });
        
        console.log('   - Heaviest lift:', heaviestLift);
        
        // Calculate longest streak
        const longestStreak = this.calculateLongestStreak();
        
        console.log('   - Longest streak:', longestStreak);
        
        return new WorkoutStats(
            totalWorkouts,
            averageWorkoutsPerWeek,
            heaviestLift,
            longestStreak
        );
    }
    
    calculateLongestStreak() {
        const sortedWorkouts = [...this.workoutHistory].sort((a, b) => 
            a.startTime.getTime() - b.startTime.getTime()
        );
        
        let longestStreak = 0;
        let currentStreak = 0;
        let lastWorkoutDate = null;
        
        sortedWorkouts.forEach(session => {
            const workoutDate = new Date(session.startTime);
            workoutDate.setHours(0, 0, 0, 0);
            
            if (lastWorkoutDate) {
                const daysBetween = Math.floor((workoutDate - lastWorkoutDate) / (24 * 60 * 60 * 1000));
                
                if (daysBetween <= 1) {
                    currentStreak++;
                } else {
                    longestStreak = Math.max(longestStreak, currentStreak);
                    currentStreak = 1;
                }
            } else {
                currentStreak = 1;
            }
            
            lastWorkoutDate = workoutDate;
        });
        
        return Math.max(longestStreak, currentStreak);
    }
    
    calculateWorkoutFrequency(timeframe) {
        console.log('📊 WorkoutFrequencyCalculator.calculate called with', this.workoutHistory.length, 'workouts, timeframe:', timeframe, 'weeks');
        
        const now = new Date();
        const weeks = Timeframe.getWeeks(timeframe);
        const startDate = new Date(now.getTime() - (weeks * 7 * 24 * 60 * 60 * 1000));
        
        console.log('   - Start date:', startDate);
        console.log('   - Now:', now);
        
        const weeklyData = [];
        
        for (let weekOffset = 0; weekOffset < weeks; weekOffset++) {
            const weekStart = new Date(startDate.getTime() + (weekOffset * 7 * 24 * 60 * 60 * 1000));
            const weekEnd = new Date(weekStart.getTime() + (6 * 24 * 60 * 60 * 1000));
            
            const workoutsInWeek = this.workoutHistory.filter(session => 
                session.startTime >= weekStart && session.startTime <= weekEnd
            );
            
            console.log('   - Week', weekOffset + ':', weekStart, 'to', weekEnd, '-', workoutsInWeek.length, 'workouts');
            
            weeklyData.push(new WeeklyWorkoutData(weekStart, workoutsInWeek.length));
        }
        
        console.log('   - Total weekly data points:', weeklyData.length);
        return weeklyData;
    }
    
    calculateExerciseProgression(exercise, metric, timeframe) {
        const now = new Date();
        const weeks = Timeframe.getWeeks(timeframe);
        const startDate = new Date(now.getTime() - (weeks * 7 * 24 * 60 * 60 * 1000));
        
        const recentWorkouts = this.workoutHistory.filter(session => 
            session.startTime >= startDate
        );
        
        const dataPoints = [];
        
        recentWorkouts
            .sort((a, b) => a.startTime.getTime() - b.startTime.getTime())
            .forEach(session => {
                const workoutExercise = session.template.exerciseInstances.find(instance => 
                    instance.exercise.name === exercise.name
                );
                
                if (workoutExercise) {
                    const value = this.calculateMetricValue(workoutExercise, metric);
                    if (value > 0) {
                        dataPoints.push(new ProgressionDataPoint(session.startTime, value));
                    }
                }
            });
        
        return dataPoints;
    }
    
    calculateMetricValue(workoutExercise, metric) {
        switch (metric) {
            case AnalyticsMetric.WEIGHT:
                // For weight progression, use the working weight
                return workoutExercise.sets[0]?.weight || 0.0;
                
            case AnalyticsMetric.REPS:
                // For reps, use final set reps for AMRAP, sum for Pyramid
                switch (workoutExercise.exercise.progressionType) {
                    case ProgressionType.AMRAP:
                    case ProgressionType.FREE:
                        return workoutExercise.sets[workoutExercise.sets.length - 1]?.actualReps || 0;
                    case ProgressionType.PYRAMID:
                        return workoutExercise.sets
                            .filter(set => set.actualReps !== null)
                            .reduce((sum, set) => sum + set.actualReps, 0);
                }
                break;
                
            case AnalyticsMetric.VOLUME:
                // For volume, calculate total kg lifted
                return workoutExercise.sets
                    .filter(set => set.actualReps !== null)
                    .reduce((sum, set) => sum + (set.weight * set.actualReps), 0);
        }
        
        return 0;
    }
    
    // MARK: - Event Listeners
    listeners = new Map();
    
    addListener(event, callback) {
        if (!this.listeners.has(event)) {
            this.listeners.set(event, []);
        }
        this.listeners.get(event).push(callback);
    }
    
    removeListener(event, callback) {
        if (this.listeners.has(event)) {
            const callbacks = this.listeners.get(event);
            const index = callbacks.indexOf(callback);
            if (index > -1) {
                callbacks.splice(index, 1);
            }
        }
    }
    
    notifyListeners(event) {
        if (this.listeners.has(event)) {
            this.listeners.get(event).forEach(callback => callback());
        }
    }
    
    // MARK: - Export Data
    exportData() {
        const exportData = {
            exercises: this.exercises.map(exercise => exercise.toJSON()),
            workoutTemplates: this.workoutTemplates.map(template => template.toJSON()),
            workoutHistory: this.workoutHistory.map(session => session.toJSON()),
            exportDate: new Date().toISOString(),
            version: '1.0'
        };
        
        const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `lazygym-export-${new Date().toISOString().split('T')[0]}.json`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }
}

// Create singleton instance
window.dataManager = new DataManager();
