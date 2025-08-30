//
//  ContentView.swift
//  spajam2025 Watch App
//
//  Created by 梶村拓斗 on 2025/08/30.
//

import SwiftUI
import Combine

struct ContentView: View {
    // MARK: - State
    @State private var isRunning = false
    @State private var startDate: Date?
    @State private var accumulated: TimeInterval = 0 // total elapsed when not running
    @State private var displayedElapsed: TimeInterval = 0

    // Timer to drive UI updates while running (lightweight interval for watch)
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text(formattedTime(displayedElapsed))
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.vertical, 6)

                HStack(spacing: 10) {
                    Button(action: toggleRun) {
                        Label(isRunning ? "一時停止" : "開始",
                              systemImage: isRunning ? "pause.fill" : "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isRunning ? .orange : .green)

                    Button(role: .destructive, action: reset) {
                        Label("リセット", systemImage: "stop.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .disabled(isRunning == true || (accumulated <= 0.0 && displayedElapsed <= 0.0))
                }

                // Navigate to a new page
                NavigationLink {
                    DetailView(elapsed: displayedElapsed)
                } label: {
                    Label("詳細", systemImage: "chevron.right")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            // Drive the displayed time while running
            .onReceive(timer) { _ in
                if isRunning, let start = startDate {
                    displayedElapsed = accumulated + Date().timeIntervalSince(start)
                } else {
                    displayedElapsed = accumulated
                }
            }
            // Ensure the displayed time is correct on appear
            .onAppear {
                displayedElapsed = accumulated
            }
        }
    }

    // MARK: - Actions
    private func toggleRun() {
        print("Toggle")
        if isRunning {
            // Pause
            if let start = startDate {
                accumulated += Date().timeIntervalSince(start)
            }
            startDate = nil
            isRunning = false
            displayedElapsed = accumulated
        } else {
            // Start
            startDate = Date()
            isRunning = true
        }
    }

    private func reset() {
        isRunning = false
        startDate = nil
        accumulated = 0
        displayedElapsed = 0
    }

    // MARK: - Formatting
    private func formattedTime(_ interval: TimeInterval) -> String {
        // Represent as H:MM:SS.hh when >= 1 hour, otherwise MM:SS.hh
        let hundredths = Int((interval * 100).rounded())
        let hours = hundredths / 360000
        let minutes = (hundredths / 6000) % 60
        let seconds = (hundredths / 100) % 60
        let hs = hundredths % 100

        if hours > 0 {
            return String(format: "%d:%02d:%02d.%02d", hours, minutes, seconds, hs)
        } else {
            return String(format: "%02d:%02d.%02d", minutes, seconds, hs)
        }
    }
}

#Preview {
    ContentView()
}
