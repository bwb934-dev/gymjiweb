//
//  HistoryView.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var isExporting = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("View", selection: $selectedTab) {
                    Text("History").tag(0)
                    Text("Analytics").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(Theme.Spacing.md)
                
                // Content
                if selectedTab == 0 {
                    historyContent
                } else {
                    AnalyticsView()
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !dataManager.workoutHistory.isEmpty && selectedTab == 0 {
                        Button("Export") {
                            exportToExcel()
                        }
                        .disabled(isExporting)
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: shareItems)
            }
        }
    }
    
    private var historyContent: some View {
        List {
            if dataManager.workoutHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("No workout history")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Complete some workouts to see your progress here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .listRowSeparator(.hidden)
            } else {
                ForEach(dataManager.workoutHistory.sorted(by: { $0.startTime > $1.startTime })) { session in
                    WorkoutHistoryRow(session: session)
                }
            }
        }
    }
    
    private func exportToExcel() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let fileURL = ExcelExporter.exportWorkoutHistory(dataManager.workoutHistory) else {
                DispatchQueue.main.async {
                    isExporting = false
                    print("Failed to export workout history")
                }
                return
            }
            
            DispatchQueue.main.async {
                isExporting = false
                shareItems = [fileURL]
                showingShareSheet = true
            }
        }
    }
}

struct WorkoutHistoryRow: View {
    let session: WorkoutSession
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.template.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(session.startTime, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("\(session.template.exerciseInstances.count) exercises")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let endTime = session.endTime {
                    let duration = endTime.timeIntervalSince(session.startTime)
                    Text(formatDuration(duration))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress indicator
            let completedExercises = session.template.exerciseInstances.filter { $0.isCompleted }.count
            let totalExercises = session.template.exerciseInstances.count
            
            if totalExercises > 0 {
                HStack {
                    Text("Progress: \(completedExercises)/\(totalExercises)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    ProgressView(value: Double(completedExercises), total: Double(totalExercises))
                        .frame(width: 100)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            WorkoutSessionDetailView(session: session)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct WorkoutSessionDetailView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Workout Info") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(session.template.name)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Started")
                        Spacer()
                        Text(session.startTime, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    if let endTime = session.endTime {
                        HStack {
                            Text("Duration")
                            Spacer()
                            Text(formatDuration(endTime.timeIntervalSince(session.startTime)))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Exercises") {
                    ForEach(session.template.exerciseInstances) { exerciseInstance in
                        ExerciseDetailRow(exerciseInstance: exerciseInstance)
                    }
                }
            }
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct ExerciseDetailRow: View {
    let exerciseInstance: WorkoutExerciseInstance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exerciseInstance.exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if exerciseInstance.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Text(exerciseInstance.exercise.progressionType.displayName)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(progressionColor)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                Text("\(exerciseInstance.sets.count) sets")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Sets details
            ForEach(exerciseInstance.sets) { set in
                HStack {
                    Text("Set \(exerciseInstance.sets.firstIndex(where: { $0.id == set.id })! + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let actualReps = set.actualReps {
                        Text("\(actualReps) reps")
                            .font(.caption)
                            .foregroundColor(.primary)
                    } else {
                        Text("Not completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(String(format: "%.1f", set.weight)) kg")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var progressionColor: Color {
        switch exerciseInstance.exercise.progressionType {
        case .amrap:
            return .blue
        case .pyramid:
            return .green
        case .free:
            return .orange
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(DataManager.shared)
}
