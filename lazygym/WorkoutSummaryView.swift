//
//  WorkoutSummaryView.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import SwiftUI

struct WorkoutSummaryView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    
    private var duration: TimeInterval {
        guard let endTime = session.endTime else { return 0 }
        return endTime.timeIntervalSince(session.startTime)
    }
    
    private var totalSets: Int {
        return session.template.exerciseInstances.reduce(0) { total, exercise in
            total + exercise.sets.filter { $0.isCompleted }.count
        }
    }
    
    private var totalReps: Int {
        return session.template.exerciseInstances.reduce(0) { total, exercise in
            total + exercise.sets.filter { $0.isCompleted }.compactMap { $0.actualReps }.reduce(0, +)
        }
    }
    
    private var totalVolume: Double {
        return session.template.exerciseInstances.reduce(0) { total, exercise in
            total + exercise.sets.filter { $0.isCompleted }.reduce(0) { setTotal, set in
                setTotal + (Double(set.actualReps ?? 0) * set.weight)
            }
        }
    }
    
    private var completedExercises: [WorkoutExerciseInstance] {
        return session.template.exerciseInstances.filter { $0.isCompleted }
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
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Header
            VStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.success)
                
                Text("Workout Complete!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(session.template.name)
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.secondary)
            }
            .padding(.top, Theme.Spacing.sm)
            
            // Summary Stats - Compact Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.Spacing.sm) {
                CompactSummaryRow(
                    icon: "clock.fill",
                    title: "Duration",
                    value: formatTime(duration),
                    color: Theme.Colors.info
                )
                
                CompactSummaryRow(
                    icon: "list.bullet",
                    title: "Sets",
                    value: "\(totalSets)",
                    color: Theme.Colors.success
                )
                
                CompactSummaryRow(
                    icon: "repeat",
                    title: "Reps",
                    value: "\(totalReps)",
                    color: Theme.Colors.warning
                )
                
                CompactSummaryRow(
                    icon: "scalemass.fill",
                    title: "Volume",
                    value: String(format: "%.1f kg", totalVolume),
                    color: Theme.Colors.accent
                )
            }
            .padding(.horizontal, Theme.Spacing.md)
            
            // Exercise Details - Only if there are exercises
            if !completedExercises.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Exercise Details")
                        .font(.headline)
                        .padding(.horizontal, Theme.Spacing.md)
                    
                    ForEach(completedExercises.prefix(2)) { exercise in
                        CompactExerciseCard(exercise: exercise)
                    }
                    
                    if completedExercises.count > 2 {
                        Text("+ \(completedExercises.count - 2) more exercises")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.secondary)
                            .padding(.horizontal, Theme.Spacing.md)
                    }
                }
            }
            
            Spacer()
        }
        .navigationTitle("Workout Summary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    Haptics.buttonPress()
                    // Set the tab first, then dismiss
                    DispatchQueue.main.async {
                        selectedTab = 0 // Navigate to homepage
                    }
                    dismiss()
                }
            }
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        Card {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(Theme.Spacing.lg)
        }
    }
}

struct ExerciseDetailCard: View {
    let exercise: WorkoutExercise
    
    private var completedSets: [WorkoutSet] {
        return exercise.sets.filter { $0.isCompleted }
    }
    
    private var progressionInfo: String {
        switch exercise.exercise.progressionType {
        case .amrap:
            if let lastSet = completedSets.last {
                return "Last set: \(lastSet.actualReps ?? 0) reps @ \(String(format: "%.1f", lastSet.weight))kg"
            }
            return "AMRAP exercise"
        case .pyramid:
            let baseReps = exercise.exercise.baseReps
            let actualReps = completedSets.compactMap { $0.actualReps }
            return "Base: \(baseReps) reps, Actual: \(actualReps.map(String.init).joined(separator: ", "))"
        case .free:
            if let lastSet = completedSets.last {
                return "Last set: \(lastSet.actualReps ?? 0) reps @ \(String(format: "%.1f", lastSet.weight))kg"
            }
            return "Free exercise"
        }
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack {
                        Text(exercise.exercise.name)
                            .font(.headline)
                    
                    Spacer()
                    
                    Text(exercise.exercise.progressionType.displayName)
                        .captionText()
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(exercise.exercise.progressionType == .amrap ? Theme.Colors.info.opacity(0.2) : 
                                   exercise.exercise.progressionType == .free ? Theme.Colors.warning.opacity(0.2) : 
                                   Theme.Colors.success.opacity(0.2))
                        .foregroundColor(exercise.exercise.progressionType == .amrap ? Theme.Colors.info : 
                                        exercise.exercise.progressionType == .free ? Theme.Colors.warning : 
                                        Theme.Colors.success)
                        .cornerRadius(Theme.CornerRadius.sm)
                }
                
                Text(progressionInfo)
                    .secondaryText()
                
                if !completedSets.isEmpty {
                    HStack {
                        Text("Sets completed: \(completedSets.count)")
                            .captionText()
                            .foregroundColor(Theme.Colors.secondary)
                        
                        Spacer()
                        
                        Text("Total reps: \(completedSets.compactMap { $0.actualReps }.reduce(0, +))")
                            .captionText()
                            .foregroundColor(Theme.Colors.secondary)
                    }
                }
            }
            .padding(Theme.Spacing.lg)
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

struct CompactSummaryRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.Colors.secondary)
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.sm)
    }
}

struct CompactExerciseCard: View {
    let exercise: WorkoutExerciseInstance
    
    private var completedSets: [WorkoutSet] {
        return exercise.sets.filter { $0.isCompleted }
    }
    
    private var progressionInfo: String {
        switch exercise.exercise.progressionType {
        case .amrap:
            if let lastSet = completedSets.last {
                return "\(lastSet.actualReps ?? 0) reps @ \(String(format: "%.1f", lastSet.weight))kg"
            }
            return "AMRAP"
        case .pyramid:
            let actualReps = completedSets.compactMap { $0.actualReps }
            return "\(actualReps.map(String.init).joined(separator: ", "))"
        case .free:
            if let lastSet = completedSets.last {
                return "\(lastSet.actualReps ?? 0) reps @ \(String(format: "%.1f", lastSet.weight))kg"
            }
            return "Free"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(progressionInfo)
                    .font(.caption)
                    .foregroundColor(Theme.Colors.secondary)
            }
            
            Spacer()
            
            Text("\(completedSets.count) sets")
                .font(.caption)
                .foregroundColor(Theme.Colors.secondary)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.sm)
    }
}

#Preview {
    WorkoutSummaryView(session: WorkoutSession(template: WorkoutTemplate(name: "Sample Workout")), selectedTab: .constant(0))
}
