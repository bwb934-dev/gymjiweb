/**
 * Progression Calculator for LazyGym Web App
 * Replicates the SwiftUI app's progression logic
 */

const { ProgressionType, WorkoutFocus } = window.LazyGymModels;

class ProgressionCalculator {
    
    // MARK: - AMRAP Progression
    static calculateAMRAPProgression(exercise, finalSetReps, workoutFocus = WorkoutFocus.FULL) {
        let weightIncrement;
        
        if (finalSetReps < 5) {
            // Keep same weight
            return exercise.currentWeight;
        } else if (finalSetReps < 10) {
            // Add +1kg (upper body) or +2.5kg (lower body)
            weightIncrement = this.isUpperBodyExercise(exercise, workoutFocus) ? 1.0 : 2.5;
        } else {
            // Add +2kg (upper body) or +5kg (lower body)
            weightIncrement = this.isUpperBodyExercise(exercise, workoutFocus) ? 2.0 : 5.0;
        }
        
        return exercise.currentWeight + weightIncrement;
    }
    
    // Helper function to determine if an exercise is upper body
    static isUpperBodyExercise(exercise, workoutFocus) {
        // Priority 1: Exercise-specific body part
        if (exercise.bodyPart) {
            return exercise.bodyPart === WorkoutFocus.UPPER;
        }
        
        // Priority 2: Workout focus
        if (workoutFocus === WorkoutFocus.UPPER) {
            return true;
        } else if (workoutFocus === WorkoutFocus.LOWER) {
            return false;
        }
        
        // Priority 3: Legacy isUpperBody (for migration)
        return exercise.isUpperBody;
        
        // Default: Upper (as specified in requirements)
    }
    
    // MARK: - Pyramid Progression
    static calculatePyramidProgression(exercise, completedSets) {
        // For Pyramid progression, use all actual reps from the completed workout
        // This preserves the exact performance from the last workout
        const actualReps = completedSets
            .filter(set => set.actualReps !== null)
            .map(set => set.actualReps);
        
        console.log('🔍 Pyramid Progression Debug:');
        console.log('   - Completed sets:', completedSets.length);
        console.log('   - Actual reps:', actualReps);
        console.log('   - Previous currentReps:', exercise.currentReps || []);
        
        // Return the actual reps from the last workout as the new current reps
        return actualReps;
    }
    
    // MARK: - Generate Sets for Exercise
    static generateSetsForExercise(exercise) {
        switch (exercise.progressionType) {
            case ProgressionType.AMRAP:
                // AMRAP: 3 sets of 5 reps + 1 set to failure
                const amrapSets = [];
                
                // 3 sets of 5 reps
                for (let i = 0; i < 3; i++) {
                    amrapSets.push(new WorkoutSet(5, exercise.currentWeight));
                }
                
                // 1 set to failure (0 means "to failure")
                amrapSets.push(new WorkoutSet(0, exercise.currentWeight));
                
                return amrapSets;
                
            case ProgressionType.PYRAMID:
                // Pyramid: Use currentReps if available, otherwise use percentage calculations
                const pyramidSets = [];
                
                console.log('🔍 Pyramid Set Generation Debug:');
                console.log('   - Exercise:', exercise.name);
                console.log('   - CurrentReps:', exercise.currentReps || []);
                console.log('   - BaseReps:', exercise.baseReps);
                
                if (exercise.currentReps && exercise.currentReps.length > 0) {
                    console.log('   - Using currentReps:', exercise.currentReps);
                    // Use the actual reps from the last workout
                    exercise.currentReps.forEach(reps => {
                        pyramidSets.push(new WorkoutSet(reps, exercise.currentWeight));
                    });
                } else {
                    console.log('   - Using percentage calculations');
                    // Fall back to percentage calculations (100%, 70%, 50%, 50% of base reps)
                    const baseReps = exercise.baseReps;
                    pyramidSets.push(new WorkoutSet(baseReps, exercise.currentWeight)); // 100%
                    pyramidSets.push(new WorkoutSet(Math.floor(baseReps * 0.7), exercise.currentWeight)); // 70%
                    pyramidSets.push(new WorkoutSet(Math.floor(baseReps * 0.5), exercise.currentWeight)); // 50%
                    pyramidSets.push(new WorkoutSet(Math.floor(baseReps * 0.5), exercise.currentWeight)); // 50%
                }
                
                console.log('   - Generated sets:', pyramidSets.map(set => set.plannedReps));
                return pyramidSets;
                
            case ProgressionType.FREE:
                // Free: Same structure as AMRAP (3×5 + 1 set to failure) but no auto progression
                const freeSets = [];
                
                // 3 sets of 5 reps
                for (let i = 0; i < 3; i++) {
                    freeSets.push(new WorkoutSet(5, exercise.currentWeight));
                }
                
                // 1 set to failure (0 means "to failure")
                freeSets.push(new WorkoutSet(0, exercise.currentWeight));
                
                return freeSets;
                
            default:
                console.warn('Unknown progression type:', exercise.progressionType);
                return [];
        }
    }
    
    // MARK: - Generate Sets for Exercise Instance
    static generateSetsForExerciseInstance(instance) {
        const { WorkoutSet } = window.LazyGymModels;
        
        switch (instance.effectiveProgressionType) {
            case ProgressionType.AMRAP:
                // AMRAP: 3 sets of 5 reps + 1 set to failure
                const amrapSets = [];
                const weight = instance.effectiveWeight;
                
                // 3 sets of 5 reps
                for (let i = 0; i < 3; i++) {
                    amrapSets.push(new WorkoutSet(5, weight));
                }
                
                // 1 set to failure (0 means "to failure")
                amrapSets.push(new WorkoutSet(0, weight));
                
                return amrapSets;
                
            case ProgressionType.PYRAMID:
                // Pyramid: Use currentReps if available, otherwise use percentage calculations
                const weight = instance.effectiveWeight;
                const pyramidSets = [];
                
                console.log('🔍 Pyramid Set Generation Debug (Instance):');
                console.log('   - Exercise:', instance.exercise.name);
                console.log('   - CurrentReps:', instance.exercise.currentReps || []);
                console.log('   - BaseReps:', instance.effectiveBaseReps);
                
                if (instance.exercise.currentReps && instance.exercise.currentReps.length > 0) {
                    console.log('   - Using currentReps:', instance.exercise.currentReps);
                    // Use the actual reps from the last workout
                    instance.exercise.currentReps.forEach(reps => {
                        pyramidSets.push(new WorkoutSet(reps, weight));
                    });
                } else {
                    console.log('   - Using percentage calculations');
                    // Fall back to percentage calculations (100%, 70%, 50%, 50% of base reps)
                    const baseReps = instance.effectiveBaseReps;
                    pyramidSets.push(new WorkoutSet(baseReps, weight)); // 100%
                    pyramidSets.push(new WorkoutSet(Math.floor(baseReps * 0.7), weight)); // 70%
                    pyramidSets.push(new WorkoutSet(Math.floor(baseReps * 0.5), weight)); // 50%
                    pyramidSets.push(new WorkoutSet(Math.floor(baseReps * 0.5), weight)); // 50%
                }
                
                console.log('   - Generated sets:', pyramidSets.map(set => set.plannedReps));
                return pyramidSets;
                
            case ProgressionType.FREE:
                // Free: Same structure as AMRAP (3×5 + 1 set to failure) but no auto progression
                const freeSets = [];
                const freeWeight = instance.effectiveWeight;
                
                // 3 sets of 5 reps
                for (let i = 0; i < 3; i++) {
                    freeSets.push(new WorkoutSet(5, freeWeight));
                }
                
                // 1 set to failure (0 means "to failure")
                freeSets.push(new WorkoutSet(0, freeWeight));
                
                return freeSets;
                
            default:
                console.warn('Unknown progression type:', instance.effectiveProgressionType);
                return [];
        }
    }
}

// Export the ProgressionCalculator class
window.ProgressionCalculator = ProgressionCalculator;
