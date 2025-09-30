/**
 * Data Models for LazyGym Web App
 * Replicates the SwiftUI app's data structures
 */

// MARK: - Enums
const ProgressionType = {
    AMRAP: 'amrap',
    PYRAMID: 'pyramid',
    FREE: 'free',
    
    getDisplayName(type) {
        switch (type) {
            case this.AMRAP: return 'AMRAP';
            case this.PYRAMID: return 'Pyramid';
            case this.FREE: return 'Free';
            default: return type;
        }
    },
    
    getAllTypes() {
        return [this.AMRAP, this.PYRAMID, this.FREE];
    }
};

const WorkoutFocus = {
    UPPER: 'upper',
    LOWER: 'lower',
    FULL: 'full',
    
    getDisplayName(focus) {
        switch (focus) {
            case this.UPPER: return 'Upper Body';
            case this.LOWER: return 'Lower Body';
            case this.FULL: return 'Full Body';
            default: return focus;
        }
    },
    
    getAllTypes() {
        return [this.UPPER, this.LOWER, this.FULL];
    }
};

// MARK: - Exercise Model
class Exercise {
    constructor(name, progressionType, isUpperBody = true, currentWeight = 0, baseReps = 10, bodyPart = null) {
        this.id = this.generateId();
        this.name = name;
        this.progressionType = progressionType;
        this.isUpperBody = isUpperBody; // Legacy support
        this.bodyPart = bodyPart || (isUpperBody ? WorkoutFocus.UPPER : WorkoutFocus.LOWER);
        this.currentWeight = currentWeight;
        this.baseReps = baseReps;
        this.currentReps = null; // For pyramid progression
        this.lastWorkoutDate = null;
    }
    
    generateId() {
        return 'exercise_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    // Convert to JSON for storage
    toJSON() {
        return {
            id: this.id,
            name: this.name,
            progressionType: this.progressionType,
            isUpperBody: this.isUpperBody,
            bodyPart: this.bodyPart,
            currentWeight: this.currentWeight,
            baseReps: this.baseReps,
            currentReps: this.currentReps,
            lastWorkoutDate: this.lastWorkoutDate
        };
    }
    
    // Create from JSON
    static fromJSON(data) {
        const exercise = new Exercise(
            data.name,
            data.progressionType,
            data.isUpperBody,
            data.currentWeight,
            data.baseReps,
            data.bodyPart
        );
        exercise.id = data.id;
        exercise.currentReps = data.currentReps;
        exercise.lastWorkoutDate = data.lastWorkoutDate ? new Date(data.lastWorkoutDate) : null;
        return exercise;
    }
}

// MARK: - Workout Set Model
class WorkoutSet {
    constructor(plannedReps, weight) {
        this.id = this.generateId();
        this.plannedReps = plannedReps;
        this.actualReps = null;
        this.weight = weight;
        this.isCompleted = false;
        this.completedAt = null;
    }
    
    generateId() {
        return 'set_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    // Complete the set with actual reps
    complete(actualReps) {
        this.actualReps = actualReps;
        this.isCompleted = true;
        this.completedAt = new Date();
    }
    
    // Convert to JSON for storage
    toJSON() {
        return {
            id: this.id,
            plannedReps: this.plannedReps,
            actualReps: this.actualReps,
            weight: this.weight,
            isCompleted: this.isCompleted,
            completedAt: this.completedAt
        };
    }
    
    // Create from JSON
    static fromJSON(data) {
        const set = new WorkoutSet(data.plannedReps, data.weight);
        set.id = data.id;
        set.actualReps = data.actualReps;
        set.isCompleted = data.isCompleted;
        set.completedAt = data.completedAt ? new Date(data.completedAt) : null;
        return set;
    }
}

// MARK: - Workout Exercise Instance Model
class WorkoutExerciseInstance {
    constructor(exercise, progressionType = null, amrapWeight = null, pyramidBaseReps = null, notes = '') {
        this.id = this.generateId();
        this.exercise = exercise;
        this.progressionType = progressionType || exercise.progressionType;
        this.amrapWeight = amrapWeight;
        this.pyramidBaseReps = pyramidBaseReps;
        this.notes = notes;
        this.sets = [];
        this.isCompleted = false;
    }
    
    generateId() {
        return 'instance_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    // Get the effective progression type
    get effectiveProgressionType() {
        return this.progressionType;
    }
    
    // Get the effective weight for AMRAP
    get effectiveWeight() {
        if (this.progressionType === ProgressionType.AMRAP) {
            return this.amrapWeight !== null ? this.amrapWeight : this.exercise.currentWeight;
        }
        return this.exercise.currentWeight;
    }
    
    // Get the effective base reps for Pyramid
    get effectiveBaseReps() {
        if (this.progressionType === ProgressionType.PYRAMID) {
            return this.pyramidBaseReps !== null ? this.pyramidBaseReps : this.exercise.baseReps;
        }
        return this.exercise.baseReps;
    }
    
    // Convert to JSON for storage
    toJSON() {
        return {
            id: this.id,
            exercise: this.exercise.toJSON(),
            progressionType: this.progressionType,
            amrapWeight: this.amrapWeight,
            pyramidBaseReps: this.pyramidBaseReps,
            notes: this.notes,
            sets: this.sets.map(set => set.toJSON()),
            isCompleted: this.isCompleted
        };
    }
    
    // Create from JSON
    static fromJSON(data) {
        const exercise = Exercise.fromJSON(data.exercise);
        const instance = new WorkoutExerciseInstance(
            exercise,
            data.progressionType,
            data.amrapWeight,
            data.pyramidBaseReps,
            data.notes
        );
        instance.id = data.id;
        instance.sets = data.sets.map(setData => WorkoutSet.fromJSON(setData));
        instance.isCompleted = data.isCompleted;
        return instance;
    }
}

// MARK: - Workout Exercise Model (Legacy)
class WorkoutExercise {
    constructor(exercise) {
        this.id = this.generateId();
        this.exercise = exercise;
        this.sets = [];
        this.isCompleted = false;
    }
    
    generateId() {
        return 'workout_exercise_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    // Convert to new WorkoutExerciseInstance
    toInstance() {
        return new WorkoutExerciseInstance(
            this.exercise,
            this.exercise.progressionType,
            this.exercise.currentWeight,
            this.exercise.baseReps,
            ''
        );
    }
    
    // Convert to JSON for storage
    toJSON() {
        return {
            id: this.id,
            exercise: this.exercise.toJSON(),
            sets: this.sets.map(set => set.toJSON()),
            isCompleted: this.isCompleted
        };
    }
    
    // Create from JSON
    static fromJSON(data) {
        const exercise = Exercise.fromJSON(data.exercise);
        const workoutExercise = new WorkoutExercise(exercise);
        workoutExercise.id = data.id;
        workoutExercise.sets = data.sets.map(setData => WorkoutSet.fromJSON(setData));
        workoutExercise.isCompleted = data.isCompleted;
        return workoutExercise;
    }
}

// MARK: - Workout Template Model
class WorkoutTemplate {
    constructor(name, exercises = [], exerciseInstances = [], focus = WorkoutFocus.FULL) {
        this.id = this.generateId();
        this.name = name;
        this.exercises = exercises; // Legacy support
        this.exerciseInstances = exerciseInstances; // New format
        this.focus = focus;
        this.createdDate = new Date();
    }
    
    generateId() {
        return 'template_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    // Get the current exercise list (prioritizes new format)
    get currentExercises() {
        if (this.exerciseInstances.length > 0) {
            // Convert instances back to legacy format for compatibility
            return this.exerciseInstances.map(instance => {
                const workoutExercise = new WorkoutExercise(instance.exercise);
                workoutExercise.sets = instance.sets;
                workoutExercise.isCompleted = instance.isCompleted;
                return workoutExercise;
            });
        }
        return this.exercises;
    }
    
    // Migrate from legacy format to new format
    migrateToNewFormat() {
        if (this.exerciseInstances.length === 0 && this.exercises.length > 0) {
            this.exerciseInstances = this.exercises.map(exercise => exercise.toInstance());
        }
    }
    
    // Convert to JSON for storage
    toJSON() {
        return {
            id: this.id,
            name: this.name,
            exercises: this.exercises.map(exercise => exercise.toJSON()),
            exerciseInstances: this.exerciseInstances.map(instance => instance.toJSON()),
            focus: this.focus,
            createdDate: this.createdDate
        };
    }
    
    // Create from JSON
    static fromJSON(data) {
        const exercises = data.exercises.map(exerciseData => WorkoutExercise.fromJSON(exerciseData));
        const exerciseInstances = data.exerciseInstances.map(instanceData => WorkoutExerciseInstance.fromJSON(instanceData));
        const template = new WorkoutTemplate(
            data.name,
            exercises,
            exerciseInstances,
            data.focus
        );
        template.id = data.id;
        template.createdDate = new Date(data.createdDate);
        return template;
    }
}

// MARK: - Workout Session Model
class WorkoutSession {
    constructor(template) {
        this.id = this.generateId();
        this.template = template;
        this.startTime = new Date();
        this.endTime = null;
        this.isCompleted = false;
        this.currentExerciseIndex = 0;
        this.currentSetIndex = 0;
    }
    
    generateId() {
        return 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    // Complete the workout session
    complete() {
        this.endTime = new Date();
        this.isCompleted = true;
    }
    
    // Get workout duration in minutes
    getDuration() {
        if (this.endTime) {
            return Math.round((this.endTime - this.startTime) / 1000 / 60);
        }
        return Math.round((new Date() - this.startTime) / 1000 / 60);
    }
    
    // Get formatted duration string
    getFormattedDuration() {
        const minutes = this.getDuration();
        const hours = Math.floor(minutes / 60);
        const remainingMinutes = minutes % 60;
        
        if (hours > 0) {
            return `${hours}h ${remainingMinutes}m`;
        }
        return `${remainingMinutes}m`;
    }
    
    // Convert to JSON for storage
    toJSON() {
        return {
            id: this.id,
            template: this.template.toJSON(),
            startTime: this.startTime,
            endTime: this.endTime,
            isCompleted: this.isCompleted,
            currentExerciseIndex: this.currentExerciseIndex,
            currentSetIndex: this.currentSetIndex
        };
    }
    
    // Create from JSON
    static fromJSON(data) {
        const template = WorkoutTemplate.fromJSON(data.template);
        const session = new WorkoutSession(template);
        session.id = data.id;
        session.startTime = new Date(data.startTime);
        session.endTime = data.endTime ? new Date(data.endTime) : null;
        session.isCompleted = data.isCompleted;
        session.currentExerciseIndex = data.currentExerciseIndex;
        session.currentSetIndex = data.currentSetIndex;
        return session;
    }
}

// MARK: - Analytics Data Models
class WorkoutStats {
    constructor(totalWorkouts, averageWorkoutsPerWeek, heaviestLift, longestStreak) {
        this.totalWorkouts = totalWorkouts;
        this.averageWorkoutsPerWeek = averageWorkoutsPerWeek;
        this.heaviestLift = heaviestLift;
        this.longestStreak = longestStreak;
    }
}

class WeeklyWorkoutData {
    constructor(weekStart, workoutCount) {
        this.id = this.generateId();
        this.weekStart = weekStart;
        this.workoutCount = workoutCount;
    }
    
    generateId() {
        return 'weekly_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
}

class ProgressionDataPoint {
    constructor(date, value) {
        this.id = this.generateId();
        this.date = date;
        this.value = value;
    }
    
    generateId() {
        return 'progression_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
}

// MARK: - Analytics Metrics
const AnalyticsMetric = {
    WEIGHT: 'weight',
    REPS: 'reps',
    VOLUME: 'volume',
    
    getDisplayName(metric) {
        switch (metric) {
            case this.WEIGHT: return 'Weight';
            case this.REPS: return 'Reps';
            case this.VOLUME: return 'Volume';
            default: return metric;
        }
    },
    
    getAllMetrics() {
        return [this.WEIGHT, this.REPS, this.VOLUME];
    }
};

// MARK: - Timeframe
const Timeframe = {
    EIGHT_WEEKS: 'eightWeeks',
    TWELVE_WEEKS: 'twelveWeeks',
    
    getDisplayName(timeframe) {
        switch (timeframe) {
            case this.EIGHT_WEEKS: return '8 Weeks';
            case this.TWELVE_WEEKS: return '12 Weeks';
            default: return timeframe;
        }
    },
    
    getWeeks(timeframe) {
        switch (timeframe) {
            case this.EIGHT_WEEKS: return 8;
            case this.TWELVE_WEEKS: return 12;
            default: return 12;
        }
    },
    
    getAllTimeframes() {
        return [this.EIGHT_WEEKS, this.TWELVE_WEEKS];
    }
};

// Export all classes and enums for use in other modules
window.LazyGymModels = {
    Exercise,
    WorkoutSet,
    WorkoutExercise,
    WorkoutExerciseInstance,
    WorkoutTemplate,
    WorkoutSession,
    WorkoutStats,
    WeeklyWorkoutData,
    ProgressionDataPoint,
    ProgressionType,
    WorkoutFocus,
    AnalyticsMetric,
    Timeframe
};
