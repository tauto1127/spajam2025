//
//  DetailView.swift
//  spajam2025 Watch App
//
//  Created by GitHub Copilot on 2025/08/30.
//

import SwiftUI
import HealthKit

struct DetailView: View {
    let elapsed: TimeInterval
    @State private var authMessage: String = ""
    private let healthStore = HKHealthStore()

    var body: some View {
        VStack(spacing: 12) {
            // Show snapshot of elapsed time
            Text(formattedTime(elapsed))
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.6)

            // Request authorization button
            Button {
                Task { await requestAuthorization() }
            } label: {
                Label("リクエスト", systemImage: "heart.text.square")
            }
            .buttonStyle(.borderedProminent)

            // Status
            if !authMessage.isEmpty {
                Label(authMessage, systemImage: "heart.text.square")
                    .font(.footnote)
            }
        }
        .padding()
        .navigationTitle("詳細")
     }

    // Format helper
    private func formattedTime(_ interval: TimeInterval) -> String {
        let hundredths = Int((interval * 100).rounded())
        let hours = hundredths / 360000
        let minutes = (hundredths / 6000) % 60
        let seconds = (hundredths / 100) % 60
        let hs = hundredths % 100
        if hours > 0 { return String(format: "%d:%02d:%02d.%02d", hours, minutes, seconds, hs) }
        return String(format: "%02d:%02d.%02d", minutes, seconds, hs)
    }

    func requestAuthorization() async {
        print("54")
        let allTypes: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceCycling),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceWheelchair),
            HKQuantityType(.heartRate)
        ]
        print("62")
        do {
            // Check that Health data is available on the device.
            if HKHealthStore.isHealthDataAvailable() {
                
                // Asynchronously request authorization to the data.
                // 
                try await healthStore.requestAuthorization(toShare: allTypes, read: allTypes)
            }
        } catch {
            
            // Typically, authorization requests only fail if you haven't set the
            // usage and share descriptions in your app's Info.plist, or if
            // Health data isn't available on the current device.
            fatalError("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
        }
        print("あいうえお")
    }
}

#Preview {
    DetailView(elapsed: 123.45)
}
