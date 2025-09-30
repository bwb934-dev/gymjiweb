//
//  WorkoutSelectionView.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import SwiftUI

struct WorkoutSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingActiveWorkout = false
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            List {
                if dataManager.workoutTemplates.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No workouts available")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Create some workouts first to start training")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(dataManager.workoutTemplates) { template in
                        WorkoutSelectionRow(template: template, showingActiveWorkout: $showingActiveWorkout)
                    }
                }
            }
            .navigationTitle("Select Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingActiveWorkout) {
                ActiveWorkoutView(selectedTab: $selectedTab)
            }
        }
    }
}

struct WorkoutSelectionRow: View {
    let template: WorkoutTemplate
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Binding var showingActiveWorkout: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Start") {
                    startWorkout()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Text("\(template.currentExercises.count) exercises")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Exercise preview
            if !template.currentExercises.isEmpty {
                HStack {
                    ForEach(template.currentExercises.prefix(3)) { workoutExercise in
                        Text(workoutExercise.exercise.name)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                    
                    if template.exercises.count > 3 {
                        Text("+\(template.exercises.count - 3) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func startWorkout() {
        dataManager.startWorkout(with: template)
        dismiss()
        showingActiveWorkout = true
    }
}

#Preview {
    WorkoutSelectionView(selectedTab: .constant(0))
        .environmentObject(DataManager.shared)
}
