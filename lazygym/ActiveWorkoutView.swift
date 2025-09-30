import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    
    @State private var currentExerciseIndex = 0
    @State private var currentSetIndex = 0
    @State private var actualReps = ""
    @State private var showingRestTimer = false
    @State private var restTimeRemaining = 0
    @State private var restTimer: Timer?
    @State private var isWorkoutComplete = false
    @State private var workoutTimer: Timer?
    @State private var workoutStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var isPaused: Bool = false
    @State private var pausedTime: TimeInterval = 0
    @State private var showingExitConfirmation = false
    
    private var currentExerciseInstance: WorkoutExerciseInstance? {
        guard let session = dataManager.currentSession else { return nil }
        let instances = session.template.exerciseInstances
        guard currentExerciseIndex < instances.count else { return nil }
        return instances[currentExerciseIndex]
    }
    
    private var currentSet: WorkoutSet? {
        guard let instance = currentExerciseInstance else { return nil }
        guard currentSetIndex < instance.sets.count else { return nil }
        return instance.sets[currentSetIndex]
    }
    
    private var isLastSet: Bool {
        guard let instance = currentExerciseInstance else { return false }
        return currentSetIndex >= instance.sets.count - 1
    }
    
    private var isLastExercise: Bool {
        guard let session = dataManager.currentSession else { return false }
        return currentExerciseIndex >= session.template.exerciseInstances.count - 1
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        Spacer(minLength: Theme.Spacing.lg)
                        
                        if isWorkoutComplete {
                            // Workout Complete - show summary immediately
                            if let session = dataManager.currentSession {
                                VStack {
                                    WorkoutSummaryView(session: session, selectedTab: $selectedTab)
                                        .onDisappear {
                                            // End the workout and dismiss when summary is closed
                                            dataManager.endWorkout()
                                            dismiss()
                                        }
                                    
                                    // Done button for summary
                                    Button("Done") {
                                        Haptics.buttonPress()
                                        dataManager.endWorkout()
                                        dismiss()
                                    }
                                    .buttonStyle(PrimaryButtonStyle())
                                    .padding(.horizontal, Theme.Spacing.lg)
                                    .padding(.bottom, Theme.Spacing.lg)
                                }
                            }
                        } else if let instance = currentExerciseInstance, let set = currentSet {
                            // Exercise Header
                            VStack(spacing: Theme.Spacing.sm) {
                                Text(instance.exercise.name)
                                    .screenTitle()
                                    .multilineTextAlignment(.center)
                                
                                Text("Set \(currentSetIndex + 1) of \(instance.sets.count)")
                                    .secondaryText()
                            }
                            .padding(.top, Theme.Spacing.lg)
                    
                            // Set Details
                            Card {
                                VStack(spacing: Theme.Spacing.lg) {
                                    // Weight Picker
                                    WeightPicker(weight: Binding(
                                        get: { 
                                            guard let instance = currentExerciseInstance,
                                                  currentSetIndex < instance.sets.count else { 
                                                print("🔍 WeightPicker get: No instance or invalid set index")
                                                return 0.0 
                                            }
                                            let weight = instance.sets[currentSetIndex].weight
                                            print("🔍 WeightPicker get: \(weight)kg for \(instance.exercise.name)")
                                            return weight
                                        },
                                        set: { newWeight in
                                            print("🔍 WeightPicker set: \(newWeight)kg for \(currentExerciseInstance?.exercise.name ?? "unknown")")
                                            updateSetWeight(newWeight: newWeight)
                                        }
                                    ))
                                    .id("weight-picker-\(currentExerciseIndex)-\(currentSetIndex)") // Force refresh when exercise/set changes
                                    
                                    // Planned Reps Display
                                    VStack(spacing: Theme.Spacing.xs) {
                                        Text("Planned Reps")
                                            .captionText()
                                        Text(set.plannedReps == 0 ? "To Failure" : "\(set.plannedReps)")
                                            .weightText()
                                            .foregroundColor(set.plannedReps == 0 ? Theme.Colors.warning : Theme.Colors.primary)
                                    }
                                }
                            }
                    
                            // Reps Input
                            VStack(spacing: Theme.Spacing.md) {
                                Text("How many reps did you complete?")
                                    .font(.headline)
                                
                                RepsCounter(
                                    reps: Binding(
                                        get: { Int(actualReps) ?? set.plannedReps },
                                        set: { actualReps = String($0) }
                                    )
                                )
                                .onAppear {
                                    if actualReps.isEmpty {
                                        actualReps = String(set.plannedReps)
                                    }
                                }
                                .onChange(of: currentSetIndex) {
                                    if actualReps.isEmpty {
                                        actualReps = String(set.plannedReps)
                                    }
                                }
                                
                                if set.plannedReps > 0 {
                                    Text("Suggested: \(set.plannedReps) reps")
                                        .captionText()
                                }
                            }
                            
                            Spacer(minLength: Theme.Spacing.lg)
                            
                            // Action Buttons
                            VStack(spacing: Theme.Spacing.md) {
                                Button(action: {
                                    Haptics.setComplete()
                                    completeSet()
                                }) {
                                    Text("Complete Set")
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                
                                if !isLastSet || !isLastExercise {
                                    Button(action: {
                                        Haptics.buttonPress()
                                        skipSet()
                                    }) {
                                        Text("Skip Set")
                                    }
                                    .buttonStyle(SecondaryButtonStyle())
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                            
                            Spacer(minLength: Theme.Spacing.lg)
                        }
                    }
                }
                .navigationBarHidden(true)
            }
            
            // Workout Timer Overlay
            if !isWorkoutComplete {
                VStack {
                    HStack {
                        TimerDisplay(time: elapsedTime, isActive: !isPaused)
                        
                        Spacer()
                        
                        // Pause/Resume Button
                        Button(action: {
                            Haptics.buttonPress()
                            togglePause()
                        }) {
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                .font(.title2)
                                .foregroundColor(Theme.Colors.accent)
                        }
                        .padding(.trailing, Theme.Spacing.sm)
                        
                        // Exit Button
                        Button(action: {
                            Haptics.buttonPress()
                            showingExitConfirmation = true
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(Theme.Colors.error)
                        }
                        .padding(.trailing, Theme.Spacing.md)
                    }
                    .padding(.top, Theme.Spacing.sm)
                    .padding(.leading, Theme.Spacing.md)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingRestTimer) {
            RestTimerView(
                onComplete: {
                    showingRestTimer = false
                }
            )
        }
        .alert("Exit Workout", isPresented: $showingExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                exitWorkout()
            }
        } message: {
            Text("Are you sure you want to exit this workout? Your progress will be saved.")
        }
        .onAppear {
            setupCurrentWorkout()
            startWorkoutTimer()
        }
        .onDisappear {
            cleanupState()
        }
    }
    
    // MARK: - Private Functions
    private func setupCurrentWorkout() {
        guard var session = dataManager.currentSession else { return }
        
        // Migrate template to new format if needed
        var updatedTemplate = session.template
        updatedTemplate.migrateToNewFormat()
        
        // Sync exercise instances with latest data from DataManager
        for exerciseIndex in 0..<updatedTemplate.exerciseInstances.count {
            var instance = updatedTemplate.exerciseInstances[exerciseIndex]
            
            // Find the latest exercise data from DataManager
            // Use name matching as a fallback since IDs might not match due to copying
            if let latestExercise = dataManager.exercises.first(where: { $0.name == instance.exercise.name }) {
                // Update the instance with the latest exercise data
                instance.exercise = latestExercise
                
                // Debug logging for weight calculation
                print("🔍 Weight Debug for \(instance.exercise.name):")
                print("   - Exercise currentWeight: \(instance.exercise.currentWeight)kg")
                print("   - Instance amrapWeight: \(instance.amrapWeight?.description ?? "nil")")
                print("   - Instance effectiveWeight: \(instance.effectiveWeight)kg")
                print("   - Progression type: \(instance.effectiveProgressionType)")
                
                // Generate sets if not already done
                if instance.sets.isEmpty {
                    instance.sets = ProgressionCalculator.generateSetsForExerciseInstance(instance)
                } else {
                    // Update weights in existing sets with the current weight
                    let currentWeight = instance.effectiveWeight
                    for setIndex in 0..<instance.sets.count {
                        instance.sets[setIndex].weight = currentWeight
                    }
                    print("🔄 Updated weights in existing sets: \(instance.exercise.name) - Weight: \(currentWeight)kg")
                }
                
                updatedTemplate.exerciseInstances[exerciseIndex] = instance
                print("🔄 Updated exercise instance: \(instance.exercise.name) - Weight: \(instance.effectiveWeight)kg")
            }
        }
        
        session.template = updatedTemplate
        dataManager.currentSession = session
    }
    
    private func completeSet() {
        guard let instance = currentExerciseInstance,
              let set = currentSet else { return }
        
        // For all sets, default to planned reps if actualReps is empty
        let reps: Int
        if actualReps.isEmpty {
            reps = set.plannedReps
        } else {
            guard let parsedReps = Int(actualReps) else { return }
            reps = parsedReps
        }
        
        print("✅ Completing set: \(instance.exercise.name) - Set \(currentSetIndex + 1) - \(reps) reps")
        print("   - Exercise ID: \(instance.exercise.id)")
        print("   - Set Index: \(currentSetIndex)")
        print("   - Total Sets: \(instance.sets.count)")
        
        Haptics.setComplete()
        
        // Update the set with actual reps
        var updatedSet = set
        updatedSet.actualReps = reps
        updatedSet.isCompleted = true
        
        // Update the exercise in the session
        if var session = dataManager.currentSession {
            var updatedTemplate = session.template
            var updatedExercise = instance
            updatedExercise.sets[currentSetIndex] = updatedSet
            
            // Check if all sets are completed
            let allSetsCompleted = updatedExercise.sets.allSatisfy { $0.isCompleted }
            if allSetsCompleted {
                updatedExercise.isCompleted = true
            }
            
            // Update the exercise in the template
            if let exerciseIndex = updatedTemplate.exerciseInstances.firstIndex(where: { $0.exercise.id == instance.exercise.id }) {
                updatedTemplate.exerciseInstances[exerciseIndex].sets = updatedExercise.sets
                updatedTemplate.exerciseInstances[exerciseIndex].isCompleted = updatedExercise.isCompleted
            }
            
            session.template = updatedTemplate
            dataManager.currentSession = session
            
            print("📝 Updated exercise instance: \(instance.exercise.name) - Set \(currentSetIndex + 1) marked as completed")
        }
        
        // Move to next set or complete workout
        nextSet()
    }
    
    private func skipSet() {
        print("⏭️ Skipping set: \(currentExerciseInstance?.exercise.name ?? "Unknown") - Set \(currentSetIndex + 1)")
        nextSet()
    }
    
    private func nextSet() {
        let wasLastSet = isLastSet
        let wasLastExercise = isLastExercise
        
        if isLastSet {
            if isLastExercise {
                // Workout complete - show completion screen
                Haptics.workoutComplete()
                isWorkoutComplete = true
                return
            } else {
                // Move to next exercise
                currentExerciseIndex += 1
                currentSetIndex = 0
            }
        } else {
            // Move to next set
            currentSetIndex += 1
        }
        
        actualReps = ""
        
        // Show rest timer if not the last set of the last exercise
        if !(wasLastSet && wasLastExercise) {
            showingRestTimer = true
        }
    }
    
    // MARK: - Timer Functions
    private func startWorkoutTimer() {
        // Only set start time if not already set (for initial start)
        if workoutStartTime == nil {
            workoutStartTime = Date()
        }
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = workoutStartTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func stopWorkoutTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func updateSetWeight(newWeight: Double) {
        print("🔍 updateSetWeight called with: \(newWeight)kg")
        guard let instance = currentExerciseInstance else { 
            print("🔍 updateSetWeight: No current exercise")
            return 
        }
        
        print("🔍 updateSetWeight: Exercise: \(instance.exercise.name), Set: \(currentSetIndex + 1)")
        
        // Update the weight in the current set
        if currentSetIndex < instance.sets.count {
            print("🔍 updateSetWeight: Calling dataManager.updateSetWeight")
            dataManager.updateSetWeight(
                exerciseId: instance.exercise.id,
                setIndex: currentSetIndex,
                newWeight: newWeight
            )
        } else {
            print("🔍 updateSetWeight: Invalid set index \(currentSetIndex)")
        }
    }
    
    // MARK: - Pause/Resume Functions
    private func togglePause() {
        if isPaused {
            resumeWorkout()
        } else {
            pauseWorkout()
        }
    }
    
    private func pauseWorkout() {
        isPaused = true
        stopWorkoutTimer()
        pausedTime = elapsedTime
        print("⏸️ Workout paused at \(formatTime(elapsedTime))")
    }
    
    private func resumeWorkout() {
        isPaused = false
        workoutStartTime = Date().addingTimeInterval(-pausedTime)
        startWorkoutTimer()
        print("▶️ Workout resumed at \(formatTime(elapsedTime))")
    }
    
    // MARK: - State Management
    private func cleanupState() {
        print("🧹 Cleaning up ActiveWorkoutView state")
        stopWorkoutTimer()
        restTimer?.invalidate()
        restTimer = nil
        
        // Reset state variables
        currentExerciseIndex = 0
        currentSetIndex = 0
        actualReps = ""
        isWorkoutComplete = false
        isPaused = false
        elapsedTime = 0
        pausedTime = 0
        showingExitConfirmation = false
    }
    
    // MARK: - Exit Functions
    private func exitWorkout() {
        print("🚪 Exiting workout - saving progress")
        Haptics.buttonPress()
        
        // Save current progress by ending the workout
        dataManager.endWorkout()
        
        // Navigate back to home
        selectedTab = 0
        dismiss()
    }
}

struct RestTimerView: View {
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeRemaining: Int = 90 // 1:30 default
    @State private var timer: Timer?
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Rest Time")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Timer Display
                VStack(spacing: 8) {
                    Text(timeString)
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("remaining")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.blue, lineWidth: 8)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                }
                
                // Add 30s Button
                Button("+ 30s") {
                    timeRemaining += 30
                }
                .buttonStyle(.bordered)
                .disabled(timer == nil) // Only allow adding time when timer is running
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Skip Rest") {
                        timer?.invalidate()
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Cancel") {
                        timer?.invalidate()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var progress: Double {
        let totalSeconds = 90 // Default 1:30
        return Double(totalSeconds - timeRemaining) / Double(totalSeconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                onComplete()
            }
        }
    }
}

#Preview {
    ActiveWorkoutView(selectedTab: .constant(0))
        .environmentObject(DataManager.shared)
}