//
//  AddWorkoutView.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import SwiftUI

struct AddWorkoutView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName = ""
    @State private var exerciseInstances: [WorkoutExerciseInstance] = []
    @State private var showingExerciseConfig = false
    @State private var selectedExerciseForConfig: Exercise?
    @State private var isSaving = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var workoutFocus: WorkoutFocus = .full
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Workout Name Input
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Workout Name")
                            .font(.headline)
                        
                        TextField("Enter workout name", text: $workoutName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .disableAutocorrection(false)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.lg)
                    
                    // Workout Focus Selector
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Body Focus")
                            .font(.headline)
                        
                        Picker("Body Focus", selection: $workoutFocus) {
                            ForEach(WorkoutFocus.allCases, id: \.self) { focus in
                                Text(focus.displayName).tag(focus)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    
                    // Workout Sequence Section
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        HStack {
                            Text("Workout Sequence")
                                .font(.headline)
                            
                            Spacer()
                            
                            if !exerciseInstances.isEmpty {
                                Text("\(exerciseInstances.count) exercises")
                                    .captionText()
                                    .padding(.horizontal, Theme.Spacing.sm)
                                    .padding(.vertical, Theme.Spacing.xs)
                                    .background(Theme.Colors.secondary)
                                    .cornerRadius(Theme.CornerRadius.sm)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        
                        if exerciseInstances.isEmpty {
                            VStack(spacing: Theme.Spacing.lg) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 48))
                                    .foregroundColor(Theme.Colors.secondary)
                                
                                Text("No exercises added")
                                    .font(.headline)
                                    .foregroundColor(Theme.Colors.secondary)
                                
                                Text("Tap the + button next to exercises below to add them to your workout")
                                    .secondaryText()
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(Theme.Colors.background)
                            .cornerRadius(Theme.CornerRadius.md)
                            .padding(.horizontal, Theme.Spacing.lg)
                        } else {
                            LazyVStack(spacing: Theme.Spacing.sm) {
                                ForEach(exerciseInstances) { instance in
                                    ExerciseInstanceRow(
                                        instance: instance,
                                        onRemove: {
                                            removeExerciseInstance(instance.id)
                                        },
                                        onConfigure: {
                                            selectedExerciseForConfig = instance.exercise
                                            showingExerciseConfig = true
                                        }
                                    )
                                    .padding(.horizontal, Theme.Spacing.lg)
                                }
                                .onMove(perform: moveExerciseInstances)
                            }
                        }
                    }
                    
                    // Available Exercises Section
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Available Exercises")
                            .font(.headline)
                            .padding(.horizontal, Theme.Spacing.lg)
                        
                        if dataManager.exercises.isEmpty {
                            VStack(spacing: Theme.Spacing.lg) {
                                Image(systemName: "dumbbell")
                                    .font(.system(size: 48))
                                    .foregroundColor(Theme.Colors.secondary)
                                
                                Text("No exercises available")
                                    .font(.headline)
                                    .foregroundColor(Theme.Colors.secondary)
                                
                                Text("Create some exercises first to build your workout")
                                    .secondaryText()
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(Theme.Colors.background)
                            .cornerRadius(Theme.CornerRadius.md)
                            .padding(.horizontal, Theme.Spacing.lg)
                        } else {
                            LazyVStack(spacing: Theme.Spacing.sm) {
                                ForEach(dataManager.exercises) { exercise in
                                    ExerciseListRow(
                                        exercise: exercise,
                                        onAdd: {
                                            addExerciseInstance(exercise)
                                        }
                                    )
                                    .padding(.horizontal, Theme.Spacing.lg)
                                }
                            }
                        }
                    }
                    
                    // Bottom padding for safe scrolling
                    Spacer(minLength: Theme.Spacing.xl)
                }
            }
            .navigationTitle("Create Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        Haptics.buttonPress()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Haptics.buttonPress()
                        saveWorkout()
                    }
                    .disabled(workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || exerciseInstances.isEmpty || isSaving)
                    .overlay(
                        Group {
                            if isSaving {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $showingExerciseConfig) {
                if let exercise = selectedExerciseForConfig {
                    ExerciseConfigView(
                        exercise: exercise,
                        instance: exerciseInstances.first { $0.exercise.id == exercise.id },
                        onSave: { updatedInstance in
                            updateExerciseInstance(updatedInstance)
                        }
                    )
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addExerciseInstance(_ exercise: Exercise) {
        let instance = WorkoutExerciseInstance(exercise: exercise)
        exerciseInstances.append(instance)
    }
    
    private func removeExerciseInstance(_ instanceId: UUID) {
        exerciseInstances.removeAll { $0.id == instanceId }
    }
    
    private func moveExerciseInstances(from source: IndexSet, to destination: Int) {
        exerciseInstances.move(fromOffsets: source, toOffset: destination)
    }
    
    private func updateExerciseInstance(_ updatedInstance: WorkoutExerciseInstance) {
        if let index = exerciseInstances.firstIndex(where: { $0.id == updatedInstance.id }) {
            exerciseInstances[index] = updatedInstance
        }
    }
    
    private func saveWorkout() {
        guard !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !exerciseInstances.isEmpty,
              !isSaving else { return }
        
        isSaving = true
        
        // Simulate API call with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let template = WorkoutTemplate(name: workoutName.trimmingCharacters(in: .whitespacesAndNewlines), exerciseInstances: exerciseInstances, focus: workoutFocus)
            dataManager.addWorkoutTemplate(template)
            
            // Success - dismiss the view
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - Exercise List Row (with + button)
struct ExerciseListRow: View {
    let exercise: Exercise
    let onAdd: () -> Void
    
    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(exercise.name)
                        .font(.headline)
                    
                    HStack {
                        Text(exercise.progressionType.displayName)
                            .captionText()
                            .padding(.horizontal, Theme.Spacing.xs)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(progressionColor)
                            .foregroundColor(.white)
                            .cornerRadius(Theme.CornerRadius.sm)
                        
                        Text(exercise.isUpperBody ? "Upper" : "Lower")
                            .captionText()
                            .foregroundColor(Theme.Colors.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    Haptics.buttonPress()
                    onAdd()
                }) {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.Colors.accent)
                            .font(.title3)
                        Text("Add")
                            .captionText()
                            .foregroundColor(Theme.Colors.accent)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Theme.Colors.accent.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.md)
                }
            }
            .padding(.vertical, Theme.Spacing.sm)
            .padding(.horizontal, Theme.Spacing.md)
        }
    }
    
    private var progressionColor: Color {
        switch exercise.progressionType {
        case .amrap:
            return .blue
        case .pyramid:
            return .green
        case .free:
            return .orange
        }
    }
}

// MARK: - Exercise Instance Row (in sequence)
struct ExerciseInstanceRow: View {
    let instance: WorkoutExerciseInstance
    let onRemove: () -> Void
    let onConfigure: () -> Void
    
    var body: some View {
        Card {
            HStack {
                // Drag handle
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(Theme.Colors.secondary)
                    .font(.caption)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(instance.exercise.name)
                        .font(.headline)
                    
                    HStack {
                        Text(instance.effectiveProgressionType.displayName)
                            .captionText()
                            .padding(.horizontal, Theme.Spacing.xs)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(progressionColor)
                            .foregroundColor(.white)
                            .cornerRadius(Theme.CornerRadius.sm)
                        
                        if instance.effectiveProgressionType == .amrap {
                            Text("\(Int(instance.effectiveWeight))kg")
                                .captionText()
                                .foregroundColor(Theme.Colors.secondary)
                        } else {
                            Text("\(instance.effectiveBaseReps) reps")
                                .captionText()
                                .foregroundColor(Theme.Colors.secondary)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: Theme.Spacing.sm) {
                    Button(action: {
                        Haptics.buttonPress()
                        onConfigure()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Theme.Colors.secondary)
                            .font(.title3)
                    }
                    
                    Button(action: {
                        Haptics.buttonPress()
                        onRemove()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(Theme.Colors.error)
                            .font(.title2)
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.sm)
            .padding(.horizontal, Theme.Spacing.md)
        }
    }
    
    private var progressionColor: Color {
        switch instance.effectiveProgressionType {
        case .amrap:
            return .blue
        case .pyramid:
            return .green
        case .free:
            return .orange
        }
    }
}

// MARK: - Exercise Configuration View
struct ExerciseConfigView: View {
    let exercise: Exercise
    let instance: WorkoutExerciseInstance?
    let onSave: (WorkoutExerciseInstance) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var progressionType: ProgressionType
    @State private var amrapWeight: Double
    @State private var pyramidBaseReps: Int
    @State private var notes: String
    
    init(exercise: Exercise, instance: WorkoutExerciseInstance?, onSave: @escaping (WorkoutExerciseInstance) -> Void) {
        self.exercise = exercise
        self.instance = instance
        self.onSave = onSave
        
        // Initialize state with instance values or exercise defaults
        if let instance = instance {
            self._progressionType = State(initialValue: instance.progressionType)
            self._amrapWeight = State(initialValue: instance.amrapWeight ?? exercise.currentWeight)
            self._pyramidBaseReps = State(initialValue: instance.pyramidBaseReps ?? exercise.baseReps)
            self._notes = State(initialValue: instance.notes)
        } else {
            self._progressionType = State(initialValue: exercise.progressionType)
            self._amrapWeight = State(initialValue: exercise.currentWeight)
            self._pyramidBaseReps = State(initialValue: exercise.baseReps)
            self._notes = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    Text(exercise.name)
                        .font(.headline)
                }
                
                Section("Progression Type") {
                    Picker("Progression Type", selection: $progressionType) {
                        ForEach(ProgressionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if progressionType == .amrap {
                    Section("AMRAP Settings") {
                        HStack {
                            Text("Working Weight")
                            Spacer()
                            TextField("Weight", value: $amrapWeight, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("kg")
                                .foregroundColor(Theme.Colors.secondary)
                        }
                    }
                } else if progressionType == .pyramid {
                    Section("Pyramid Settings") {
                        HStack {
                            Text("Base Reps")
                            Spacer()
                            TextField("Reps", value: $pyramidBaseReps, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                } else if progressionType == .free {
                    Section("Free Settings") {
                        HStack {
                            Text("Starting Weight")
                            Spacer()
                            TextField("Weight", value: $amrapWeight, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("kg")
                                .foregroundColor(Theme.Colors.secondary)
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Configure Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        Haptics.buttonPress()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Haptics.buttonPress()
                        saveConfiguration()
                    }
                }
            }
        }
    }
    
    private func saveConfiguration() {
        let updatedInstance = WorkoutExerciseInstance(
            exercise: exercise,
            progressionType: progressionType,
            amrapWeight: (progressionType == .amrap || progressionType == .free) ? amrapWeight : nil,
            pyramidBaseReps: progressionType == .pyramid ? pyramidBaseReps : nil,
            notes: notes
        )
        onSave(updatedInstance)
        dismiss()
    }
}

// MARK: - Legacy Exercise Selection Row (for backward compatibility)
struct ExerciseSelectionRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(exercise.progressionType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(progressionColor)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    Text(exercise.isUpperBody ? "Upper" : "Lower")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
                .font(.title2)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private var progressionColor: Color {
        switch exercise.progressionType {
        case .amrap:
            return .blue
        case .pyramid:
            return .green
        case .free:
            return .orange
        }
    }
}

struct EditWorkoutView: View {
    let template: WorkoutTemplate
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName: String
    @State private var selectedExercises: Set<UUID>
    
    init(template: WorkoutTemplate) {
        self.template = template
        self._workoutName = State(initialValue: template.name)
        self._selectedExercises = State(initialValue: Set(template.exercises.map { $0.exercise.id }))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Workout Name
                VStack(alignment: .leading) {
                    Text("Workout Name")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextField("Enter workout name", text: $workoutName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Exercise Selection
                VStack(alignment: .leading) {
                    Text("Select Exercises")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List {
                        ForEach(dataManager.exercises) { exercise in
                            ExerciseSelectionRow(
                                exercise: exercise,
                                isSelected: selectedExercises.contains(exercise.id)
                            ) {
                                toggleExercise(exercise.id)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty || selectedExercises.isEmpty)
                }
            }
        }
    }
    
    private func toggleExercise(_ exerciseId: UUID) {
        if selectedExercises.contains(exerciseId) {
            selectedExercises.remove(exerciseId)
        } else {
            selectedExercises.insert(exerciseId)
        }
    }
    
    private func saveWorkout() {
        let selectedExerciseObjects = dataManager.exercises.filter { selectedExercises.contains($0.id) }
        let workoutExercises = selectedExerciseObjects.map { WorkoutExercise(exercise: $0) }
        
        var updatedTemplate = template
        updatedTemplate.name = workoutName
        updatedTemplate.exercises = workoutExercises
        
        dataManager.updateWorkoutTemplate(updatedTemplate)
        dismiss()
    }
}

#Preview {
    AddWorkoutView()
        .environmentObject(DataManager.shared)
}
