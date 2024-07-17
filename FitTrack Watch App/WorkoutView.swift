import SwiftUI
import HealthKit

struct WorkoutView: View {
    var exerciseType: ExerciseType
    @Binding var isWorkoutStarted: Bool

    @State private var heartRate: Double = 0
    @State private var caloriesBurned: Int = 0
    @State private var duration: TimeInterval = 0
    @State private var repetitions: Int = 0

    private var healthKitManager = HealthKitManager.shared
    private var motionManager = MotionManager.shared
    private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(exerciseType: ExerciseType, isWorkoutStarted: Binding<Bool>) {
        self.exerciseType = exerciseType
        self._isWorkoutStarted = isWorkoutStarted
    }

    var body: some View {
        VStack {
            Text("Exercise: \(exerciseType.rawValue)")
            Text("Heart Rate: \(heartRate, specifier: "%.1f") bpm")
            Text("Calories Burned: \(caloriesBurned) cal")
            Text("Duration: \(formattedDuration())")

            if exerciseType != .general {
                Text("Repetitions: \(repetitions)")
            }

            Button("End Workout") {
                endWorkout()
            }
            .padding()
        }
        .onAppear(perform: startWorkout)
        .onReceive(timer) { _ in
            duration += 1
            updateCaloriesBurned()
        }
    }

    private func startWorkout() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                healthKitManager.startHeartRateQuery { sample in
                    let heartRateUnit = HKUnit(from: "count/min")
                    DispatchQueue.main.async {
                        self.heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                    }
                }
            }
        }

        if exerciseType != .general {
            motionManager.requestAuthorization { success in
                if success {
                    startRepetitionCounting()
                }
            }
        }
    }

    private func startRepetitionCounting() {
        motionManager.startGyroscopeUpdates { data in
            // Process gyroscope data to count repetitions
            // This example assumes simple z-axis movement detection for a bench press
            let threshold = 1.0 // Adjust threshold as needed
            if abs(data.rotationRate.z) > threshold {
                repetitions += 1
            }
        }
    }

    private func updateCaloriesBurned() {
        // Simplified calories burned calculation: adjust as needed
        let caloriesPerMinute = 8.0 // Adjust based on exercise type and user data
        let minutes = duration / 60
        caloriesBurned = Int(minutes * caloriesPerMinute)
    }

    private func formattedDuration() -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func endWorkout() {
        timer.upstream.connect().cancel()
        motionManager.stopGyroscopeUpdates()
        // Perform any additional cleanup or saving of data here
        isWorkoutStarted = false // Navigate back to the home screen
    }
}
