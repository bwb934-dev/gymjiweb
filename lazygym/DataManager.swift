//
//  DataManager.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var exercises: [Exercise] = []
    @Published var workoutTemplates: [WorkoutTemplate] = []
    @Published var workoutHistory: [WorkoutSession] = []
    @Published var currentSession: WorkoutSession?
    
    private let userDefaults = UserDefaults.standard
    private let exercisesKey = "SavedExercises"
    private let templatesKey = "SavedWorkoutTemplates"
    private let historyKey = "SavedWorkoutHistory"
    
    // Thread safety
    private let queue = DispatchQueue(label: "com.lazygym.datamanager", qos: .userInitiated)
    
    private init() {
        loadData()
        // Force reload default exercises with new list
        reloadDefaultExercises()
        // Temporarily disable migration to prevent crashes
        // migrateData()
    }
    
    // MARK: - Data Persistence
    private func loadData() {
        loadExercises()
        loadWorkoutTemplates()
        loadWorkoutHistory()
    }
    
    private func saveData() {
        saveExercises()
        saveWorkoutTemplates()
        saveWorkoutHistory()
    }
    
    // MARK: - Exercise Management
    func addExercise(_ exercise: Exercise) {
        queue.async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.exercises.append(exercise)
                self.saveExercises()
            }
        }
    }
    
    func updateExercise(_ exercise: Exercise) {
        queue.async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let index = self.exercises.firstIndex(where: { $0.id == exercise.id }) {
                    self.exercises[index] = exercise
                    self.saveExercises()
                }
            }
        }
    }
    
    func deleteExercise(_ exercise: Exercise) {
        exercises.removeAll { $0.id == exercise.id }
        saveExercises()
    }
    
    func resetToDefaultExercises() {
        exercises.removeAll()
        addDefaultExercises()
    }
    
    func clearAllExercises() {
        exercises.removeAll()
        saveExercises()
        print("   - Cleared all exercises")
    }
    
    func reloadDefaultExercises() {
        print("🔄 Reloading default exercises...")
        exercises.removeAll()
        addDefaultExercises()
        print("✅ Default exercises reloaded")
    }
    
    func removeDuplicateExercises() {
        var uniqueExercises: [Exercise] = []
        var seenNames: Set<String> = []
        
        for exercise in exercises {
            if !seenNames.contains(exercise.name) {
                uniqueExercises.append(exercise)
                seenNames.insert(exercise.name)
            }
        }
        
        let removedCount = exercises.count - uniqueExercises.count
        exercises = uniqueExercises
        saveExercises()
        print("   - Removed \(removedCount) duplicate exercises")
    }
    
    private func loadExercises() {
        print("🔍 DataManager.loadExercises called")
        if let data = userDefaults.data(forKey: exercisesKey),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            exercises = decoded
            print("   - Loaded \(exercises.count) exercises:")
            for exercise in exercises {
                print("   - \(exercise.name): currentReps = \(exercise.currentReps ?? [])")
            }
            
            // Remove duplicates if any exist
            let originalCount = exercises.count
            removeDuplicateExercises()
            if originalCount != exercises.count {
                print("   - Found and removed duplicate exercises")
            }
        } else {
            print("   - No exercises found in UserDefaults, adding defaults")
            // Add default exercises if none exist
            addDefaultExercises()
        }
    }
    
    private func addDefaultExercises() {
        // Only add default exercises if none exist
        if exercises.isEmpty {
            let defaultExercises = [
                Exercise(name: "Squat", progressionType: .amrap, isUpperBody: false, currentWeight: 60.0),
                Exercise(name: "Deadlift", progressionType: .amrap, isUpperBody: false, currentWeight: 80.0),
                Exercise(name: "Pull up", progressionType: .pyramid, isUpperBody: true, currentWeight: 0.0, baseReps: 8),
                Exercise(name: "Pull up", progressionType: .amrap, isUpperBody: true, currentWeight: 0.0),
                Exercise(name: "Push-up", progressionType: .amrap, isUpperBody: true, currentWeight: 20.0),
                Exercise(name: "Kettlebell swing", progressionType: .pyramid, isUpperBody: false, currentWeight: 24.0, baseReps: 15),
                Exercise(name: "Overhead Press", progressionType: .amrap, isUpperBody: true, currentWeight: 20.0)
            ]
            
            exercises = defaultExercises
            saveExercises()
            print("   - Added \(defaultExercises.count) default exercises")
        } else {
            print("   - Exercises already exist, skipping default creation")
        }
    }
    
    private func saveExercises() {
        do {
            let encoded = try JSONEncoder().encode(exercises)
            userDefaults.set(encoded, forKey: exercisesKey)
            print("✅ Successfully saved \(exercises.count) exercises")
        } catch {
            print("❌ Error saving exercises: \(error)")
            // Could implement fallback or user notification here
        }
    }
    
    // MARK: - Workout Template Management
    func addWorkoutTemplate(_ template: WorkoutTemplate) {
        // Migrate template to new format if needed
        var migratedTemplate = template
        migratedTemplate.migrateToNewFormat()
        workoutTemplates.append(migratedTemplate)
        saveWorkoutTemplates()
    }
    
    func updateWorkoutTemplate(_ template: WorkoutTemplate) {
        if let index = workoutTemplates.firstIndex(where: { $0.id == template.id }) {
            workoutTemplates[index] = template
            saveWorkoutTemplates()
        }
    }
    
    func deleteWorkoutTemplate(_ template: WorkoutTemplate) {
        workoutTemplates.removeAll { $0.id == template.id }
        saveWorkoutTemplates()
    }
    
    private func loadWorkoutTemplates() {
        if let data = userDefaults.data(forKey: templatesKey),
           let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: data) {
            workoutTemplates = decoded
            print("🔍 Loaded workout templates:")
            for template in workoutTemplates {
                print("   - \(template.name): \(template.exercises.count) exercises")
            }
            
            // Check if all templates have 0 exercises and reset if needed
            let allEmpty = workoutTemplates.allSatisfy { $0.exercises.isEmpty }
            if allEmpty && !workoutTemplates.isEmpty {
                print("🔍 All existing templates are empty, clearing and creating defaults...")
                workoutTemplates.removeAll()
                addDefaultWorkoutTemplates()
            }
        } else {
            // Add default workout templates if none exist
            print("🔍 No existing workout templates found, creating defaults...")
            addDefaultWorkoutTemplates()
        }
    }
    
    private func addDefaultWorkoutTemplates() {
        // Create a default workout template using existing exercises
        // Find exercises by name to ensure we use the same instances
        print("🔍 Creating default workout templates...")
        print("   - Available exercises: \(exercises.map { $0.name })")
        
        let pushUpExercise = exercises.first { $0.name == "Push-up" }
        let squatExercise = exercises.first { $0.name == "Squat" }
        let deadliftExercise = exercises.first { $0.name == "Deadlift" }
        
        var workoutExercises: [WorkoutExercise] = []
        
        if let pushUp = pushUpExercise {
            workoutExercises.append(WorkoutExercise(exercise: pushUp))
            print("   - Added Push-up exercise")
        }
        if let squat = squatExercise {
            workoutExercises.append(WorkoutExercise(exercise: squat))
            print("   - Added Squat exercise")
        }
        if let deadlift = deadliftExercise {
            workoutExercises.append(WorkoutExercise(exercise: deadlift))
            print("   - Added Deadlift exercise")
        }
        
        if !workoutExercises.isEmpty {
            let defaultTemplate = WorkoutTemplate(
                name: "Full Body Workout",
                exercises: workoutExercises
            )
            
            workoutTemplates = [defaultTemplate]
            saveWorkoutTemplates()
            print("   - Created default template with \(workoutExercises.count) exercises")
        } else {
            print("   - ❌ No exercises found to create default template")
        }
    }
    
    private func saveWorkoutTemplates() {
        do {
            let encoded = try JSONEncoder().encode(workoutTemplates)
            userDefaults.set(encoded, forKey: templatesKey)
            print("✅ Successfully saved \(workoutTemplates.count) workout templates")
        } catch {
            print("❌ Error saving workout templates: \(error)")
        }
    }
    
    // MARK: - Workout History Management
    func addWorkoutSession(_ session: WorkoutSession) {
        workoutHistory.append(session)
        saveWorkoutHistory()
    }
    
    func updateWorkoutSession(_ session: WorkoutSession) {
        if let index = workoutHistory.firstIndex(where: { $0.id == session.id }) {
            workoutHistory[index] = session
            saveWorkoutHistory()
        }
    }
    
    private func loadWorkoutHistory() {
        print("🔍 DataManager.loadWorkoutHistory called")
        if let data = userDefaults.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            workoutHistory = decoded
            print("   - Loaded \(workoutHistory.count) workout sessions")
            for (index, session) in workoutHistory.enumerated() {
                print("   - Session \(index): \(session.template.name) - \(session.startTime)")
            }
        } else {
            print("   - No workout history found in UserDefaults")
            workoutHistory = []
            // Temporarily disable sample data to prevent crashes
            // addSampleWorkoutHistory()
        }
    }
    
    private func addSampleWorkoutHistory() {
        print("   - Adding sample workout history for testing")
        
        // Create sample exercises first
        let sampleExercise1 = Exercise(name: "Push-up", progressionType: .amrap, isUpperBody: true, currentWeight: 20.0)
        let sampleExercise2 = Exercise(name: "Squat", progressionType: .pyramid, isUpperBody: false, currentWeight: 60.0, baseReps: 10)
        let sampleExercise3 = Exercise(name: "Deadlift", progressionType: .amrap, isUpperBody: false, currentWeight: 80.0)
        
        // Add exercises to the exercises array only if they don't already exist
        if !exercises.contains(where: { $0.name == "Push-up" }) {
            exercises.append(sampleExercise1)
        }
        if !exercises.contains(where: { $0.name == "Squat" }) {
            exercises.append(sampleExercise2)
        }
        if !exercises.contains(where: { $0.name == "Deadlift" }) {
            exercises.append(sampleExercise3)
        }
        saveExercises()
        
        // Create WorkoutExercise instances
        let workoutExercise1 = WorkoutExercise(exercise: sampleExercise1)
        let workoutExercise2 = WorkoutExercise(exercise: sampleExercise2)
        let workoutExercise3 = WorkoutExercise(exercise: sampleExercise3)
        
        // Create sample workout template
        let sampleTemplate = WorkoutTemplate(
            name: "Sample Workout",
            exercises: [workoutExercise1, workoutExercise2, workoutExercise3],
            focus: .full
        )
        
        // Create sample workout sessions with realistic data
        let calendar = Calendar.current
        let now = Date()
        
        var sampleSessions: [WorkoutSession] = []
        
        // Create 8 sample sessions over the past 12 weeks with progression
        for i in 0..<8 {
            let sessionDate = calendar.date(byAdding: .weekOfYear, value: -i, to: now) ?? now
            
            var session = WorkoutSession(template: sampleTemplate)
            session.startTime = sessionDate
            session.endTime = calendar.date(byAdding: .minute, value: 45, to: sessionDate) ?? sessionDate
            
            // Add realistic workout data with progression over time
            
            // Push-up progression (AMRAP)
            let pushupWeight = 20.0 + (Double(i) * 2.5) // 20kg to 37.5kg
            let pushupReps = 8 + i // 8 to 15 reps
            var pushupSets = [
                WorkoutSet(plannedReps: 5, weight: pushupWeight),
                WorkoutSet(plannedReps: 5, weight: pushupWeight),
                WorkoutSet(plannedReps: 5, weight: pushupWeight),
                WorkoutSet(plannedReps: 0, weight: pushupWeight) // AMRAP set
            ]
            pushupSets[0].actualReps = 5
            pushupSets[0].isCompleted = true
            pushupSets[1].actualReps = 5
            pushupSets[1].isCompleted = true
            pushupSets[2].actualReps = 5
            pushupSets[2].isCompleted = true
            pushupSets[3].actualReps = pushupReps
            pushupSets[3].isCompleted = true
            session.template.exerciseInstances[0].sets = pushupSets
            
            // Squat progression (Pyramid)
            let squatWeight = 60.0 + (Double(i) * 5.0) // 60kg to 95kg
            let baseReps = 10 + i // 10 to 17 reps
            var squatSets = [
                WorkoutSet(plannedReps: baseReps, weight: squatWeight),
                WorkoutSet(plannedReps: Int(Double(baseReps) * 0.7), weight: squatWeight),
                WorkoutSet(plannedReps: Int(Double(baseReps) * 0.5), weight: squatWeight),
                WorkoutSet(plannedReps: Int(Double(baseReps) * 0.5), weight: squatWeight)
            ]
            squatSets[0].actualReps = baseReps
            squatSets[0].isCompleted = true
            squatSets[1].actualReps = Int(Double(baseReps) * 0.7)
            squatSets[1].isCompleted = true
            squatSets[2].actualReps = Int(Double(baseReps) * 0.5)
            squatSets[2].isCompleted = true
            squatSets[3].actualReps = Int(Double(baseReps) * 0.5)
            squatSets[3].isCompleted = true
            session.template.exerciseInstances[1].sets = squatSets
            
            // Deadlift progression (Free)
            let deadliftWeight = 100.0 + (Double(i) * 7.5) // 100kg to 152.5kg
            var deadliftSets = [
                WorkoutSet(plannedReps: 5, weight: deadliftWeight),
                WorkoutSet(plannedReps: 5, weight: deadliftWeight),
                WorkoutSet(plannedReps: 5, weight: deadliftWeight),
                WorkoutSet(plannedReps: 0, weight: deadliftWeight) // AMRAP-style final set
            ]
            deadliftSets[0].actualReps = 5
            deadliftSets[0].isCompleted = true
            deadliftSets[1].actualReps = 5
            deadliftSets[1].isCompleted = true
            deadliftSets[2].actualReps = 5
            deadliftSets[2].isCompleted = true
            deadliftSets[3].actualReps = 3 + i
            deadliftSets[3].isCompleted = true
            session.template.exerciseInstances[2].sets = deadliftSets
            
            sampleSessions.append(session)
        }
        
        workoutHistory = sampleSessions
        saveWorkoutHistory()
        print("   - Added \(sampleSessions.count) sample workout sessions with realistic data")
        print("   - Sample data includes weights from 20kg to 152.5kg")
        print("   - Sample data includes reps from 3 to 17")
    }
    
    private func saveWorkoutHistory() {
        let encoded = try? JSONEncoder().encode(workoutHistory)
        userDefaults.set(encoded, forKey: historyKey)
        print("✅ Successfully saved \(workoutHistory.count) workout sessions")
    }
    
    // MARK: - Current Session Management
    func startWorkout(with template: WorkoutTemplate) {
        let session = WorkoutSession(template: template)
        currentSession = session
    }
    
    func endWorkout() {
        guard var session = currentSession else { return }
        session.endTime = Date()
        session.isCompleted = true
        
        // Apply progression updates to exercises
        applyProgressionUpdates(from: session)
        
        addWorkoutSession(session)
        currentSession = nil
    }
    
    private func applyProgressionUpdates(from session: WorkoutSession) {
        print("🔄 Starting progression updates...")
        
        // Migrate template to new format if needed
        var template = session.template
        template.migrateToNewFormat()
        
        print("📊 Template has \(template.exerciseInstances.count) exercise instances")
        print("📊 DataManager has \(exercises.count) exercises")
        
        // Update progression for each exercise instance
        for exerciseIndex in 0..<template.exerciseInstances.count {
            let instance = template.exerciseInstances[exerciseIndex]
            let completedSets = instance.sets.filter { $0.isCompleted }
            
            print("🏋️ Exercise: \(instance.exercise.name)")
            print("   - Exercise ID: \(instance.exercise.id)")
            print("   - Progression Type: \(instance.effectiveProgressionType)")
            print("   - Completed Sets: \(completedSets.count)")
            print("   - Total Sets: \(instance.sets.count)")
            
            if !completedSets.isEmpty {
                print("   - Final Set Reps: \(completedSets.last?.actualReps ?? 0)")
                
                // Find the base exercise in our exercise list and update it
                // Use name matching as a fallback since IDs might not match due to copying
                if let baseExerciseIndex = exercises.firstIndex(where: { $0.name == instance.exercise.name }) {
                    var baseExercise = exercises[baseExerciseIndex]
                    let oldWeight = baseExercise.currentWeight
                    
                    print("   - Base Exercise Found: \(baseExercise.name)")
                    print("   - Base Exercise ID: \(baseExercise.id)")
                    print("   - Current Weight: \(oldWeight)kg")
                    
                    // Apply progression based on the instance's effective progression type
                    switch instance.effectiveProgressionType {
                    case .amrap:
                        if let finalSet = completedSets.last, let actualReps = finalSet.actualReps {
                            let newWeight = ProgressionCalculator.calculateAMRAPProgression(exercise: baseExercise, finalSetReps: actualReps, workoutFocus: session.template.focus)
                            baseExercise.currentWeight = newWeight
                            print("   - AMRAP Progression: \(oldWeight)kg → \(newWeight)kg (final set: \(actualReps) reps)")
                        } else {
                            print("   - ❌ No final set or actual reps found")
                        }
                    case .pyramid:
                        let newCurrentReps = ProgressionCalculator.calculatePyramidProgression(exercise: baseExercise, completedSets: completedSets)
                        baseExercise.currentReps = newCurrentReps
                        print("   - Pyramid Progression: current reps updated to \(newCurrentReps)")
                    case .free:
                        // Free progression: No automatic weight progression, just update last workout date
                        print("   - Free Progression: No weight change (Free progression doesn't auto-increment)")
                    }
                    
                    baseExercise.lastWorkoutDate = Date()
                    exercises[baseExerciseIndex] = baseExercise
                    print("   - ✅ Base exercise updated")
                } else {
                    print("   - ❌ Base exercise NOT found in DataManager")
                    print("   - Available exercise IDs: \(exercises.map { $0.id })")
                }
            } else {
                print("   - ⚠️ No completed sets found")
            }
        }
        
        // Save the updated exercises
        saveExercises()
        print("💾 Progression updates saved")
    }
    
    // MARK: - Progression Updates
    func updateExerciseProgression(_ exercise: Exercise, completedSets: [WorkoutSet], workoutFocus: WorkoutFocus = .full) {
        var updatedExercise = exercise
        
        switch exercise.progressionType {
        case .amrap:
            if let finalSet = completedSets.last, let actualReps = finalSet.actualReps {
                let newWeight = ProgressionCalculator.calculateAMRAPProgression(exercise: exercise, finalSetReps: actualReps, workoutFocus: workoutFocus)
                updatedExercise.currentWeight = newWeight
            }
        case .pyramid:
            let newCurrentReps = ProgressionCalculator.calculatePyramidProgression(exercise: exercise, completedSets: completedSets)
            updatedExercise.currentReps = newCurrentReps
        case .free:
            // Free progression: No automatic weight progression
            break
        }
        
        updatedExercise.lastWorkoutDate = Date()
        updateExercise(updatedExercise)
    }
    
    // MARK: - Set Weight Updates
    func updateSetWeight(exerciseId: UUID, setIndex: Int, newWeight: Double) {
        guard var session = currentSession else { return }
        
        // Migrate template to new format if needed
        var updatedTemplate = session.template
        updatedTemplate.migrateToNewFormat()
        
        // Find the exercise in the current session using exerciseInstances
        for exerciseIndex in 0..<updatedTemplate.exerciseInstances.count {
            let instance = updatedTemplate.exerciseInstances[exerciseIndex]
            if instance.exercise.id == exerciseId && setIndex < instance.sets.count {
                // Update the weight in the set
                updatedTemplate.exerciseInstances[exerciseIndex].sets[setIndex].weight = newWeight
                session.template = updatedTemplate
                currentSession = session
                print("🏋️ Updated weight for \(instance.exercise.name) Set \(setIndex + 1) to \(newWeight)kg")
                break
            }
        }
    }
    
    // MARK: - Data Migration
    private func migrateData() {
        // Migrate exercises from isUpperBody to bodyPart
        var needsMigration = false
        
        for i in 0..<exercises.count {
            if exercises[i].bodyPart == nil {
                exercises[i].bodyPart = exercises[i].isUpperBody ? .upper : .lower
                needsMigration = true
            }
        }
        
        // Migrate workout templates from isUpperBody to focus
        for i in 0..<workoutTemplates.count {
            if workoutTemplates[i].focus == .full {
                // Check if this template has exercises that suggest a specific focus
                let hasUpperBody = workoutTemplates[i].currentExercises.contains { $0.exercise.isUpperBody }
                let hasLowerBody = workoutTemplates[i].currentExercises.contains { !$0.exercise.isUpperBody }
                
                if hasUpperBody && !hasLowerBody {
                    workoutTemplates[i].focus = .upper
                    needsMigration = true
                } else if hasLowerBody && !hasUpperBody {
                    workoutTemplates[i].focus = .lower
                    needsMigration = true
                }
                // If mixed or no exercises, keep as .full
            }
        }
        
        if needsMigration {
            saveExercises()
            saveWorkoutTemplates()
            print("🔄 Data migration completed: isUpperBody → WorkoutFocus")
        }
    }
}
