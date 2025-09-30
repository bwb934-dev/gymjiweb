//
//  Models.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import Foundation

// MARK: - Exercise Types
enum ProgressionType: String, CaseIterable, Codable {
    case amrap = "AMRAP"
    case pyramid = "Pyramid"
    case free = "Free"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Workout Focus Types
enum WorkoutFocus: String, CaseIterable, Codable {
    case upper = "Upper"
    case lower = "Lower"
    case full = "Full"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Exercise Model
struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var progressionType: ProgressionType
    var isUpperBody: Bool // Legacy support - will be migrated
    var bodyPart: WorkoutFocus? // New: specific body part for this exercise
    var currentWeight: Double // in kg
    var baseReps: Int // for pyramid progression
    var currentReps: [Int]? // actual reps from last workout (for Pyramid progression)
    var lastWorkoutDate: Date?
    
    init(name: String, progressionType: ProgressionType, isUpperBody: Bool, currentWeight: Double = 0, baseReps: Int = 10, bodyPart: WorkoutFocus? = nil) {
        self.id = UUID()
        self.name = name
        self.progressionType = progressionType
        self.isUpperBody = isUpperBody
        self.bodyPart = bodyPart
        self.currentWeight = currentWeight
        self.baseReps = baseReps
        self.currentReps = nil
    }
}

// MARK: - Set Model
struct WorkoutSet: Identifiable, Codable {
    let id: UUID
    var plannedReps: Int
    var actualReps: Int?
    var weight: Double
    var isCompleted: Bool = false
    var completedAt: Date?
    
    init(plannedReps: Int, weight: Double) {
        self.id = UUID()
        self.plannedReps = plannedReps
        self.weight = weight
    }
}

// MARK: - Workout Exercise Instance Model
struct WorkoutExerciseInstance: Identifiable, Codable {
    let id: UUID
    var exercise: Exercise
    var progressionType: ProgressionType // Per-instance override
    var amrapWeight: Double? // For AMRAP instances
    var pyramidBaseReps: Int? // For Pyramid instances
    var notes: String
    var sets: [WorkoutSet]
    var isCompleted: Bool = false
    
    init(exercise: Exercise, progressionType: ProgressionType? = nil, amrapWeight: Double? = nil, pyramidBaseReps: Int? = nil, notes: String = "") {
        self.id = UUID()
        self.exercise = exercise
        self.progressionType = progressionType ?? exercise.progressionType
        self.amrapWeight = amrapWeight
        self.pyramidBaseReps = pyramidBaseReps
        self.notes = notes
        self.sets = []
    }
    
    // Computed property to get the effective progression type
    var effectiveProgressionType: ProgressionType {
        return progressionType
    }
    
    // Computed property to get the effective weight for AMRAP
    var effectiveWeight: Double {
        if progressionType == .amrap {
            return amrapWeight ?? exercise.currentWeight
        }
        return exercise.currentWeight
    }
    
    // Computed property to get the effective base reps for Pyramid
    var effectiveBaseReps: Int {
        if progressionType == .pyramid {
            return pyramidBaseReps ?? exercise.baseReps
        }
        return exercise.baseReps
    }
}

// MARK: - Workout Exercise Model (Legacy - for backward compatibility)
struct WorkoutExercise: Identifiable, Codable {
    let id: UUID
    var exercise: Exercise
    var sets: [WorkoutSet]
    var isCompleted: Bool = false
    
    init(exercise: Exercise) {
        self.id = UUID()
        self.exercise = exercise
        self.sets = []
    }
    
    // Convert to new WorkoutExerciseInstance
    func toInstance() -> WorkoutExerciseInstance {
        return WorkoutExerciseInstance(
            exercise: exercise,
            progressionType: exercise.progressionType,
            amrapWeight: exercise.currentWeight,
            pyramidBaseReps: exercise.baseReps,
            notes: ""
        )
    }
}

// MARK: - Workout Template Model
struct WorkoutTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var exercises: [WorkoutExercise] // Legacy support
    var exerciseInstances: [WorkoutExerciseInstance] // New format
    var focus: WorkoutFocus = .full // New: workout focus (Upper/Lower/Full)
    var createdDate: Date = Date()
    
    init(name: String, exercises: [WorkoutExercise] = [], exerciseInstances: [WorkoutExerciseInstance] = [], focus: WorkoutFocus = .full) {
        self.id = UUID()
        self.name = name
        self.exercises = exercises
        self.exerciseInstances = exerciseInstances
        self.focus = focus
    }
    
    // Get the current exercise list (prioritizes new format)
    var currentExercises: [WorkoutExercise] {
        if !exerciseInstances.isEmpty {
            // Convert instances back to legacy format for compatibility
            return exerciseInstances.map { instance in
                var workoutExercise = WorkoutExercise(exercise: instance.exercise)
                workoutExercise.sets = instance.sets
                workoutExercise.isCompleted = instance.isCompleted
                return workoutExercise
            }
        }
        return exercises
    }
    
    // Migrate from legacy format to new format
    mutating func migrateToNewFormat() {
        if exerciseInstances.isEmpty && !exercises.isEmpty {
            exerciseInstances = exercises.map { $0.toInstance() }
        }
    }
}

// MARK: - Workout Session Model
struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    var template: WorkoutTemplate
    var startTime: Date
    var endTime: Date?
    var isCompleted: Bool = false
    var currentExerciseIndex: Int = 0
    var currentSetIndex: Int = 0
    
    init(template: WorkoutTemplate) {
        self.id = UUID()
        self.template = template
        self.startTime = Date()
    }
}

// MARK: - Progression Logic
struct ProgressionCalculator {
    
    // MARK: - AMRAP Progression
    static func calculateAMRAPProgression(exercise: Exercise, finalSetReps: Int, workoutFocus: WorkoutFocus = .full) -> Double {
        let weightIncrement: Double
        
        if finalSetReps < 5 {
            // Keep same weight
            return exercise.currentWeight
        } else if finalSetReps < 10 {
            // Add +1kg (upper body) or +2.5kg (lower body)
            weightIncrement = isUpperBodyExercise(exercise: exercise, workoutFocus: workoutFocus) ? 1.0 : 2.5
        } else {
            // Add +2kg (upper body) or +5kg (lower body)
            weightIncrement = isUpperBodyExercise(exercise: exercise, workoutFocus: workoutFocus) ? 2.0 : 5.0
        }
        
        return exercise.currentWeight + weightIncrement
    }
    
    // Helper function to determine if an exercise is upper body
    static func isUpperBodyExercise(exercise: Exercise, workoutFocus: WorkoutFocus) -> Bool {
        // Priority 1: Exercise-specific body part
        if let bodyPart = exercise.bodyPart {
            return bodyPart == .upper
        }
        
        // Priority 2: Workout focus
        if workoutFocus == .upper {
            return true
        } else if workoutFocus == .lower {
            return false
        }
        
        // Priority 3: Legacy isUpperBody (for migration)
        return exercise.isUpperBody
        
        // Default: Upper (as specified in requirements)
    }
    
    // MARK: - Pyramid Progression
    static func calculatePyramidProgression(exercise: Exercise, completedSets: [WorkoutSet]) -> [Int] {
        // For Pyramid progression, use all actual reps from the completed workout
        // This preserves the exact performance from the last workout
        let actualReps = completedSets.compactMap { $0.actualReps }
        
        print("   - 🔍 Pyramid Progression Debug:")
        print("   - Completed sets: \(completedSets.count)")
        print("   - Actual reps: \(actualReps)")
        print("   - Previous currentReps: \(exercise.currentReps ?? [])")
        
        // Return the actual reps from the last workout as the new current reps
        return actualReps
    }
    
    // MARK: - Generate Sets for Exercise
    static func generateSetsForExercise(_ exercise: Exercise) -> [WorkoutSet] {
        switch exercise.progressionType {
        case .amrap:
            // AMRAP: 3 sets of 5 reps + 1 set to failure
            var sets: [WorkoutSet] = []
            
            // 3 sets of 5 reps
            for _ in 0..<3 {
                sets.append(WorkoutSet(plannedReps: 5, weight: exercise.currentWeight))
            }
            
            // 1 set to failure (we'll track this differently in the UI)
            sets.append(WorkoutSet(plannedReps: 0, weight: exercise.currentWeight)) // 0 means "to failure"
            
            return sets
            
        case .pyramid:
            // Pyramid: Use currentReps if available, otherwise use percentage calculations
            var sets: [WorkoutSet] = []
            
            print("🔍 Pyramid Set Generation Debug:")
            print("   - Exercise: \(exercise.name)")
            print("   - CurrentReps: \(exercise.currentReps ?? [])")
            print("   - BaseReps: \(exercise.baseReps)")
            
            if let currentReps = exercise.currentReps, !currentReps.isEmpty {
                print("   - Using currentReps: \(currentReps)")
                // Use the actual reps from the last workout
                for reps in currentReps {
                    sets.append(WorkoutSet(plannedReps: reps, weight: exercise.currentWeight))
                }
            } else {
                print("   - Using percentage calculations")
                // Fall back to percentage calculations (100%, 70%, 50%, 50% of base reps)
                let baseReps = exercise.baseReps
                sets.append(WorkoutSet(plannedReps: baseReps, weight: exercise.currentWeight)) // 100%
                sets.append(WorkoutSet(plannedReps: Int(Double(baseReps) * 0.7), weight: exercise.currentWeight)) // 70%
                sets.append(WorkoutSet(plannedReps: Int(Double(baseReps) * 0.5), weight: exercise.currentWeight)) // 50%
                sets.append(WorkoutSet(plannedReps: Int(Double(baseReps) * 0.5), weight: exercise.currentWeight)) // 50%
            }
            
            print("   - Generated sets: \(sets.map { $0.plannedReps })")
            return sets
            
        case .free:
            // Free: Same structure as AMRAP (3×5 + 1 set to failure) but no auto progression
            var sets: [WorkoutSet] = []
            
            // 3 sets of 5 reps
            for _ in 0..<3 {
                sets.append(WorkoutSet(plannedReps: 5, weight: exercise.currentWeight))
            }
            
            // 1 set to failure (we'll track this differently in the UI)
            sets.append(WorkoutSet(plannedReps: 0, weight: exercise.currentWeight)) // 0 means "to failure"
            
            return sets
        }
    }
    
    // MARK: - Generate Sets for Exercise Instance
    static func generateSetsForExerciseInstance(_ instance: WorkoutExerciseInstance) -> [WorkoutSet] {
        switch instance.effectiveProgressionType {
        case .amrap:
            // AMRAP: 3 sets of 5 reps + 1 set to failure
            var sets: [WorkoutSet] = []
            let weight = instance.effectiveWeight
            
            // 3 sets of 5 reps
            for _ in 0..<3 {
                sets.append(WorkoutSet(plannedReps: 5, weight: weight))
            }
            
            // 1 set to failure (we'll track this differently in the UI)
            sets.append(WorkoutSet(plannedReps: 0, weight: weight)) // 0 means "to failure"
            
            return sets
            
        case .pyramid:
            // Pyramid: Use currentReps if available, otherwise use percentage calculations
            let weight = instance.effectiveWeight
            var sets: [WorkoutSet] = []
            
            print("🔍 Pyramid Set Generation Debug (Instance):")
            print("   - Exercise: \(instance.exercise.name)")
            print("   - CurrentReps: \(instance.exercise.currentReps ?? [])")
            print("   - BaseReps: \(instance.effectiveBaseReps)")
            
            if let currentReps = instance.exercise.currentReps, !currentReps.isEmpty {
                print("   - Using currentReps: \(currentReps)")
                // Use the actual reps from the last workout
                for reps in currentReps {
                    sets.append(WorkoutSet(plannedReps: reps, weight: weight))
                }
            } else {
                print("   - Using percentage calculations")
                // Fall back to percentage calculations (100%, 70%, 50%, 50% of base reps)
                let baseReps = instance.effectiveBaseReps
                sets.append(WorkoutSet(plannedReps: baseReps, weight: weight)) // 100%
                sets.append(WorkoutSet(plannedReps: Int(Double(baseReps) * 0.7), weight: weight)) // 70%
                sets.append(WorkoutSet(plannedReps: Int(Double(baseReps) * 0.5), weight: weight)) // 50%
                sets.append(WorkoutSet(plannedReps: Int(Double(baseReps) * 0.5), weight: weight)) // 50%
            }
            
            print("   - Generated sets: \(sets.map { $0.plannedReps })")
            return sets
            
        case .free:
            // Free: Same structure as AMRAP (3×5 + 1 set to failure) but no auto progression
            var sets: [WorkoutSet] = []
            let weight = instance.effectiveWeight
            
            // 3 sets of 5 reps
            for _ in 0..<3 {
                sets.append(WorkoutSet(plannedReps: 5, weight: weight))
            }
            
            // 1 set to failure (we'll track this differently in the UI)
            sets.append(WorkoutSet(plannedReps: 0, weight: weight)) // 0 means "to failure"
            
            return sets
        }
    }
}
