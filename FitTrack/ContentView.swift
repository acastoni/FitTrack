import SwiftUI

struct ContentView: View {
    @State private var selectedExercise: ExerciseType = .general
    @State private var isWorkoutStarted = false

    var body: some View {
        VStack {
            Picker("Select Exercise", selection: $selectedExercise) {
                Text("Bench Press").tag(ExerciseType.benchPress)
                Text("Pull Up").tag(ExerciseType.pullUp)
                Text("General").tag(ExerciseType.general)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if isWorkoutStarted {
                WorkoutView(exerciseType: selectedExercise)
            } else {
                Button("Start Workout") {
                    isWorkoutStarted = true
                }
                .padding()
            }
        }
    }
}
