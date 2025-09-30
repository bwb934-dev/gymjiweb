//
//  AddExerciseView.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import SwiftUI

struct AddExerciseView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var progressionType = ProgressionType.amrap
    @State private var bodyPart: WorkoutFocus = .upper
    @State private var currentWeight = ""
    @State private var baseReps = "10"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise Name", text: $name)
                    
                    Picker("Progression Type", selection: $progressionType) {
                        ForEach(ProgressionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Body Part", selection: $bodyPart) {
                        ForEach(WorkoutFocus.allCases, id: \.self) { focus in
                            Text(focus.displayName).tag(focus)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Initial Settings") {
                    TextField("Current Weight (kg)", text: $currentWeight)
                        .keyboardType(.decimalPad)
                    
                    if progressionType == .pyramid {
                        TextField("Base Reps", text: $baseReps)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section {
                    Text(progressionType == .amrap ? 
                         "AMRAP: 3 sets of 5 reps + 1 set to failure. Weight progression based on final set reps." :
                         progressionType == .pyramid ?
                         "Pyramid: 100%, 70%, 50%, 50% of base reps. Add +1 rep when you complete all sets." :
                         "Free: 3 sets of 5 reps + 1 set to failure. No automatic weight progression - you control the weights.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveExercise() {
        let weight = Double(currentWeight) ?? 0
        let reps = Int(baseReps) ?? 10
        
        let exercise = Exercise(
            name: name,
            progressionType: progressionType,
            isUpperBody: bodyPart == .upper, // Legacy support
            currentWeight: weight,
            baseReps: reps,
            bodyPart: bodyPart
        )
        
        dataManager.addExercise(exercise)
        dismiss()
    }
}

struct EditExerciseView: View {
    let exercise: Exercise
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var progressionType: ProgressionType
    @State private var bodyPart: WorkoutFocus
    @State private var currentWeight: String
    @State private var baseReps: String
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self._name = State(initialValue: exercise.name)
        self._progressionType = State(initialValue: exercise.progressionType)
        self._bodyPart = State(initialValue: exercise.bodyPart ?? (exercise.isUpperBody ? .upper : .lower))
        self._currentWeight = State(initialValue: String(format: "%.1f", exercise.currentWeight))
        self._baseReps = State(initialValue: String(exercise.baseReps))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise Name", text: $name)
                    
                    Picker("Progression Type", selection: $progressionType) {
                        ForEach(ProgressionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Body Part", selection: $bodyPart) {
                        ForEach(WorkoutFocus.allCases, id: \.self) { focus in
                            Text(focus.displayName).tag(focus)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Current Settings") {
                    TextField("Current Weight (kg)", text: $currentWeight)
                        .keyboardType(.decimalPad)
                    
                    if progressionType == .pyramid {
                        TextField("Base Reps", text: $baseReps)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveExercise() {
        let weight = Double(currentWeight) ?? 0
        let reps = Int(baseReps) ?? 10
        
        var updatedExercise = exercise
        updatedExercise.name = name
        updatedExercise.progressionType = progressionType
        updatedExercise.isUpperBody = bodyPart == .upper // Legacy support
        updatedExercise.bodyPart = bodyPart
        updatedExercise.currentWeight = weight
        updatedExercise.baseReps = reps
        
        dataManager.updateExercise(updatedExercise)
        dismiss()
    }
}

#Preview {
    AddExerciseView()
        .environmentObject(DataManager.shared)
}
