//
//  AnalyticsView.swift
//  lazygym
//
//  Created by Budr Albakri on 28.09.25.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedExercise: Exercise?
    @State private var selectedMetric: AnalyticsMetric = .weight
    @State private var selectedTimeframe: Timeframe = .twelveWeeks
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Summary Stats Cards
                    SummaryStatsView(workoutHistory: dataManager.workoutHistory)
                    
                    // Workout Frequency Chart
                    WorkoutFrequencyChart(workoutHistory: dataManager.workoutHistory, timeframe: selectedTimeframe)
                    
                    // Exercise Progression Chart
                    ExerciseProgressionChart(
                        workoutHistory: dataManager.workoutHistory,
                        selectedExercise: $selectedExercise,
                        selectedMetric: $selectedMetric,
                        timeframe: selectedTimeframe
                    )
                    
                    // Timeframe Selector
                    TimeframeSelector(selectedTimeframe: $selectedTimeframe)
                }
                .padding(Theme.Spacing.lg)
            }
            .navigationTitle("Analytics")
            .onAppear {
                if selectedExercise == nil && !dataManager.exercises.isEmpty {
                    selectedExercise = dataManager.exercises.first
                }
            }
        }
    }
}

// MARK: - Summary Stats
struct SummaryStatsView: View {
    let workoutHistory: [WorkoutSession]
    
    private var stats: WorkoutStats {
        WorkoutStatsCalculator.calculate(workoutHistory: workoutHistory)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Summary")
                .font(.headline)
                .foregroundColor(Theme.Colors.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.Spacing.md) {
                AnalyticsStatCard(
                    title: "Total Workouts",
                    value: "\(stats.totalWorkouts)",
                    icon: "figure.strengthtraining.traditional",
                    color: Theme.Colors.accent
                )
                
                AnalyticsStatCard(
                    title: "Avg/Week",
                    value: String(format: "%.1f", stats.averageWorkoutsPerWeek),
                    icon: "calendar",
                    color: Theme.Colors.success
                )
                
                AnalyticsStatCard(
                    title: "Heaviest Lift",
                    value: "\(String(format: "%.1f", stats.heaviestLift))kg",
                    icon: "dumbbell",
                    color: Theme.Colors.warning
                )
                
                AnalyticsStatCard(
                    title: "Longest Streak",
                    value: "\(stats.longestStreak) days",
                    icon: "flame",
                    color: Theme.Colors.error
                )
            }
        }
    }
}

struct AnalyticsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title2)
                    
                    Spacer()
                }
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.Colors.secondary)
            }
            .padding(Theme.Spacing.md)
        }
    }
}

// MARK: - Workout Frequency Chart
struct WorkoutFrequencyChart: View {
    let workoutHistory: [WorkoutSession]
    let timeframe: Timeframe
    
    private var weeklyData: [WeeklyWorkoutData] {
        WorkoutFrequencyCalculator.calculate(workoutHistory: workoutHistory, timeframe: timeframe)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Workout Frequency")
                .font(.headline)
                .foregroundColor(Theme.Colors.primary)
            
            Card {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    if weeklyData.isEmpty {
                        VStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "chart.bar")
                                .font(.title)
                                .foregroundColor(Theme.Colors.secondary)
                            Text("No data available")
                                .font(.subheadline)
                                .foregroundColor(Theme.Colors.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(Theme.Spacing.lg)
                    } else {
                        SimpleBarChart(data: weeklyData)
                            .frame(height: 200)
                            .padding(Theme.Spacing.md)
                    }
                }
            }
        }
    }
}

// MARK: - Exercise Progression Chart
struct ExerciseProgressionChart: View {
    let workoutHistory: [WorkoutSession]
    @Binding var selectedExercise: Exercise?
    @Binding var selectedMetric: AnalyticsMetric
    let timeframe: Timeframe
    @EnvironmentObject var dataManager: DataManager
    
    private var progressionData: [ProgressionDataPoint] {
        guard let exercise = selectedExercise else { return [] }
        return ExerciseProgressionCalculator.calculate(
            workoutHistory: workoutHistory,
            exercise: exercise,
            metric: selectedMetric,
            timeframe: timeframe
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Exercise Progression")
                .font(.headline)
                .foregroundColor(Theme.Colors.primary)
            
            // Exercise Picker
            if !dataManager.exercises.isEmpty {
                Picker("Exercise", selection: $selectedExercise) {
                    ForEach(dataManager.exercises) { exercise in
                        Text(exercise.name).tag(exercise as Exercise?)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, Theme.Spacing.md)
            }
            
            // Metric Toggle
            Picker("Metric", selection: $selectedMetric) {
                Text("Weight").tag(AnalyticsMetric.weight)
                Text("Reps").tag(AnalyticsMetric.reps)
                Text("Volume").tag(AnalyticsMetric.volume)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Theme.Spacing.md)
            
            Card {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    if progressionData.isEmpty {
                        VStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title)
                                .foregroundColor(Theme.Colors.secondary)
                            Text("No data available")
                                .font(.subheadline)
                                .foregroundColor(Theme.Colors.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(Theme.Spacing.lg)
                    } else {
                        SimpleLineChart(data: progressionData, metric: selectedMetric)
                            .frame(height: 200)
                            .padding(Theme.Spacing.md)
                    }
                }
            }
        }
    }
}

// MARK: - Timeframe Selector
struct TimeframeSelector: View {
    @Binding var selectedTimeframe: Timeframe
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Time Period")
                .font(.headline)
                .foregroundColor(Theme.Colors.primary)
            
            Picker("Timeframe", selection: $selectedTimeframe) {
                Text("8 Weeks").tag(Timeframe.eightWeeks)
                Text("12 Weeks").tag(Timeframe.twelveWeeks)
            }
            .pickerStyle(.segmented)
        }
    }
}

// MARK: - Data Models
struct WorkoutStats {
    let totalWorkouts: Int
    let averageWorkoutsPerWeek: Double
    let heaviestLift: Double
    let longestStreak: Int
}

struct WeeklyWorkoutData: Identifiable {
    let id = UUID()
    let weekStart: Date
    let workoutCount: Int
}

struct ProgressionDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

enum AnalyticsMetric: String, CaseIterable {
    case weight = "Weight"
    case reps = "Reps"
    case volume = "Volume"
    
    var displayName: String {
        return self.rawValue
    }
}

enum Timeframe: String, CaseIterable {
    case eightWeeks = "8 Weeks"
    case twelveWeeks = "12 Weeks"
    
    var weeks: Int {
        switch self {
        case .eightWeeks: return 8
        case .twelveWeeks: return 12
        }
    }
}

// MARK: - Data Calculators
struct WorkoutStatsCalculator {
    static func calculate(workoutHistory: [WorkoutSession]) -> WorkoutStats {
        print("📊 WorkoutStatsCalculator.calculate called with \(workoutHistory.count) workouts")
        
        let totalWorkouts = workoutHistory.count
        
        // Calculate average workouts per week
        let calendar = Calendar.current
        let now = Date()
        let twelveWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -12, to: now) ?? now
        
        let recentWorkouts = workoutHistory.filter { $0.startTime >= twelveWeeksAgo }
        let weeks = max(1, calendar.dateComponents([.weekOfYear], from: twelveWeeksAgo, to: now).weekOfYear ?? 1)
        let averageWorkoutsPerWeek = Double(recentWorkouts.count) / Double(weeks)
        
        print("   - Recent workouts: \(recentWorkouts.count)")
        print("   - Weeks: \(weeks)")
        print("   - Average per week: \(averageWorkoutsPerWeek)")
        
        // Calculate heaviest lift
        let heaviestLift = workoutHistory.flatMap { session in
            session.template.exerciseInstances.flatMap { exercise in
                exercise.sets.map { $0.weight }
            }
        }.max() ?? 0.0
        
        print("   - Heaviest lift: \(heaviestLift)")
        
        // Calculate longest streak
        let longestStreak = calculateLongestStreak(workoutHistory: workoutHistory)
        
        print("   - Longest streak: \(longestStreak)")
        
        return WorkoutStats(
            totalWorkouts: totalWorkouts,
            averageWorkoutsPerWeek: averageWorkoutsPerWeek,
            heaviestLift: heaviestLift,
            longestStreak: longestStreak
        )
    }
    
    private static func calculateLongestStreak(workoutHistory: [WorkoutSession]) -> Int {
        let sortedWorkouts = workoutHistory.sorted { $0.startTime < $1.startTime }
        var longestStreak = 0
        var currentStreak = 0
        var lastWorkoutDate: Date?
        
        let calendar = Calendar.current
        
        for workout in sortedWorkouts {
            let workoutDate = calendar.startOfDay(for: workout.startTime)
            
            if let lastDate = lastWorkoutDate {
                let daysBetween = calendar.dateComponents([.day], from: lastDate, to: workoutDate).day ?? 0
                
                if daysBetween <= 1 {
                    currentStreak += 1
                } else {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            lastWorkoutDate = workoutDate
        }
        
        return max(longestStreak, currentStreak)
    }
}

struct WorkoutFrequencyCalculator {
    static func calculate(workoutHistory: [WorkoutSession], timeframe: Timeframe) -> [WeeklyWorkoutData] {
        print("📊 WorkoutFrequencyCalculator.calculate called with \(workoutHistory.count) workouts, timeframe: \(timeframe.weeks) weeks")
        
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .weekOfYear, value: -timeframe.weeks, to: now) ?? now
        
        print("   - Start date: \(startDate)")
        print("   - Now: \(now)")
        
        var weeklyData: [WeeklyWorkoutData] = []
        
        for weekOffset in 0..<timeframe.weeks {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startDate) ?? startDate
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
            
            let workoutsInWeek = workoutHistory.filter { workout in
                workout.startTime >= weekStart && workout.startTime <= weekEnd
            }
            
            print("   - Week \(weekOffset): \(weekStart) to \(weekEnd) - \(workoutsInWeek.count) workouts")
            
            weeklyData.append(WeeklyWorkoutData(
                weekStart: weekStart,
                workoutCount: workoutsInWeek.count
            ))
        }
        
        print("   - Total weekly data points: \(weeklyData.count)")
        return weeklyData
    }
}

struct ExerciseProgressionCalculator {
    static func calculate(
        workoutHistory: [WorkoutSession],
        exercise: Exercise,
        metric: AnalyticsMetric,
        timeframe: Timeframe
    ) -> [ProgressionDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .weekOfYear, value: -timeframe.weeks, to: now) ?? now
        
        let recentWorkouts = workoutHistory.filter { $0.startTime >= startDate }
        
        var dataPoints: [ProgressionDataPoint] = []
        
        for workout in recentWorkouts.sorted(by: { $0.startTime < $1.startTime }) {
            if let workoutExercise = workout.template.exerciseInstances.first(where: { $0.exercise.id == exercise.id }) {
                let value = calculateMetricValue(workoutExercise: workoutExercise, metric: metric)
                if value > 0 {
                    dataPoints.append(ProgressionDataPoint(
                        date: workout.startTime,
                        value: value
                    ))
                }
            }
        }
        
        return dataPoints
    }
    
    private static func calculateMetricValue(workoutExercise: WorkoutExerciseInstance, metric: AnalyticsMetric) -> Double {
        switch metric {
        case .weight:
            // For weight progression, use the working weight
            return workoutExercise.sets.first?.weight ?? 0.0
            
        case .reps:
            // For reps, use final set reps for AMRAP, sum for Pyramid
            switch workoutExercise.exercise.progressionType {
            case .amrap, .free:
                return Double(workoutExercise.sets.last?.actualReps ?? 0)
            case .pyramid:
                return Double(workoutExercise.sets.compactMap { $0.actualReps }.reduce(0, +))
            }
            
        case .volume:
            // For volume, calculate total kg lifted
            return workoutExercise.sets.compactMap { set in
                guard let reps = set.actualReps else { return nil }
                return set.weight * Double(reps)
            }.reduce(0, +)
        }
    }
}

// MARK: - Custom Chart Components
struct SimpleBarChart: View {
    let data: [WeeklyWorkoutData]
    
    private var maxValue: Int {
        data.map { $0.workoutCount }.max() ?? 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chart
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(data) { item in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 20, height: max(4, CGFloat(item.workoutCount) / CGFloat(maxValue) * 150))
                            .cornerRadius(2)
                        
                        Text(formatWeekDate(item.weekStart))
                            .font(.caption2)
                            .foregroundColor(Theme.Colors.secondary)
                            .rotationEffect(.degrees(-45))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Y-axis labels
            HStack {
                Text("0")
                    .font(.caption2)
                    .foregroundColor(Theme.Colors.secondary)
                Spacer()
                Text("\(maxValue)")
                    .font(.caption2)
                    .foregroundColor(Theme.Colors.secondary)
            }
        }
    }
    
    private func formatWeekDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct SimpleLineChart: View {
    let data: [ProgressionDataPoint]
    let metric: AnalyticsMetric
    
    private var maxValue: Double {
        data.map { $0.value }.max() ?? 1.0
    }
    
    private var minValue: Double {
        data.map { $0.value }.min() ?? 0.0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chart
            GeometryReader { geometry in
                if data.count > 1 {
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let xStep = width / CGFloat(data.count - 1)
                        
                        for (index, point) in data.enumerated() {
                            let x = CGFloat(index) * xStep
                            let normalizedValue = (point.value - minValue) / (maxValue - minValue)
                            let y = height - (normalizedValue * height)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Theme.Colors.accent, lineWidth: 3)
                    
                    // Data points
                    ForEach(Array(data.enumerated()), id: \.offset) { index, point in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let xStep = width / CGFloat(data.count - 1)
                        let x = CGFloat(index) * xStep
                        let normalizedValue = (point.value - minValue) / (maxValue - minValue)
                        let y = height - (normalizedValue * height)
                        
                        Circle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                }
            }
            
            // Y-axis labels
            HStack {
                Text(String(format: "%.1f", minValue))
                    .font(.caption2)
                    .foregroundColor(Theme.Colors.secondary)
                Spacer()
                Text(String(format: "%.1f", maxValue))
                    .font(.caption2)
                    .foregroundColor(Theme.Colors.secondary)
            }
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(DataManager.shared)
}
