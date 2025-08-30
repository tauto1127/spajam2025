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
    @State private var restingHeartRate: String = ""
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
            
            // 値取得ボタン
            Button {
                Task { await getHealthData(); await getRestingHeartRate() }
            } label: {
                Label("値取得", systemImage: "heart.text.square")
            }

            // Status
            if !authMessage.isEmpty {
                Label(authMessage, systemImage: "heart.text.square")
                    .font(.footnote)
            }
            if !restingHeartRate.isEmpty {
                Label(restingHeartRate, systemImage: "heart.text.square")
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
    
    func getHealthData() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            await MainActor.run {
                authMessage = "Health data is not available on this device."
            }
                return
        }
        
        guard let heartType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
                    await MainActor.run { authMessage = "HeartRate type unavailable." }
                    return
                }

                let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                let query = HKSampleQuery(sampleType: heartType,
                                          predicate: nil,
                                          limit: 1,
                                          sortDescriptors: [sort]) { _, samples, error in
                    if let error = error {
                        Task { @MainActor in
                            authMessage = "Query error: \(error.localizedDescription)"
                        }
                        return
                    }

                    guard let sample = samples?.first as? HKQuantitySample else {
                        Task { @MainActor in
                            authMessage = "No heart rate data."
                        }
                        return
                    }

                    let bpmUnit = HKUnit.count().unitDivided(by: .minute())
                    let bpm = sample.quantity.doubleValue(for: bpmUnit)
                    let value = String(format: "%.0f bpm", bpm)

                    Task { @MainActor in
                        authMessage = "Latest HR: \(value)"
                    }
                }

                healthStore.execute(query)
    }
    
    func getRestingHeartRate() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            await MainActor.run {
                authMessage = "Health data is not available on this device."
            }
                return
        }
        
        guard let heartType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
                    await MainActor.run { authMessage = "HeartRate type unavailable." }
                    return
                }

                // ソート設定
                let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                // どのタイプのデータを取るか，条件，最大取得数，ソートの順番，クロージャ
                let query = HKSampleQuery(sampleType: heartType,
                                          predicate: nil,
                                          limit: 1,
                                          sortDescriptors: [sort]) { _, samples, error in
                    if let error = error {
                        Task { @MainActor in
                            restingHeartRate = "Query error: \(error.localizedDescription)"
                        }
                        return
                    }

                    guard let sample = samples?.first as? HKQuantitySample else {
                        Task { @MainActor in
                            restingHeartRate = "No heart rate data."
                        }
                        return
                    }

                    let bpmUnit = HKUnit.count().unitDivided(by: .minute())
                    let bpm = sample.quantity.doubleValue(for: bpmUnit)
                    let value = String(format: "%.0f bpm", bpm)

                    Task { @MainActor in
                        restingHeartRate = "Resting HR: \(value)"
                    }
                }

                healthStore.execute(query)
    }

    func requestAuthorization() async {
        print("54")
        let allTypes: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceCycling),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceWheelchair),
            HKQuantityType(.heartRate),
            HKQuantityType(.restingHeartRate)
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
