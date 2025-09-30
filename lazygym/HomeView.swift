//
//  HomeView.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingWorkoutSelection = false
    @State private var showingActiveWorkout = false
    @Binding var selectedTab: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Ready to Train?")
                        .screenTitle()
                }
                .padding(.top, Theme.Spacing.lg)
                
                // Quick Stats
                VStack(spacing: Theme.Spacing.md) {
                    HStack(spacing: Theme.Spacing.md) {
                        StatCard(
                            title: "Exercises",
                            value: "\(dataManager.exercises.count)",
                            icon: "dumbbell.fill",
                            color: Theme.Colors.info
                        )
                        .onTapGesture {
                            Haptics.buttonPress()
                            selectedTab = 2 // Exercises tab
                        }
                        
                        StatCard(
                            title: "Workouts",
                            value: "\(dataManager.workoutTemplates.count)",
                            icon: "list.bullet",
                            color: Theme.Colors.success
                        )
                        .onTapGesture {
                            Haptics.buttonPress()
                            selectedTab = 1 // Workouts tab
                        }
                    }
                    
                    StatCard(
                        title: "Sessions",
                        value: "\(dataManager.workoutHistory.count)",
                        icon: "chart.line.uptrend.xyaxis",
                        color: Theme.Colors.warning
                    )
                    .onTapGesture {
                        Haptics.buttonPress()
                        selectedTab = 3 // History tab
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                
                // Start Workout Button
                Button(action: {
                    Haptics.workoutStart()
                    showingWorkoutSelection = true
                }) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "play.fill")
                            .font(.title2)
                        Text("Start Workout")
                            .buttonText()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, Theme.Spacing.md)
                
                // Current Session Indicator
                if dataManager.currentSession != nil {
                    Card {
                        VStack(spacing: Theme.Spacing.sm) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(Theme.Colors.success)
                                Text("Workout in Progress")
                                    .font(.headline)
                                    .foregroundColor(Theme.Colors.success)
                            }
                            
                            Text(dataManager.currentSession?.template.name ?? "Unknown Workout")
                                .secondaryText()
                            
                            Button("Continue Workout") {
                                Haptics.buttonPress()
                                showingActiveWorkout = true
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                }
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(Theme.Colors.groupedBackground)
        .sheet(isPresented: $showingWorkoutSelection) {
            WorkoutSelectionView(selectedTab: $selectedTab)
        }
        .fullScreenCover(isPresented: $showingActiveWorkout) {
            ActiveWorkoutView(selectedTab: $selectedTab)
                .onDisappear {
                    // Reset the state when the workout view is dismissed
                    showingActiveWorkout = false
                }
        }
    }
}


#Preview {
    HomeView(selectedTab: .constant(0))
        .environmentObject(DataManager.shared)
}
