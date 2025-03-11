//
//  AlertView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/10/25.
//


import SwiftUI

struct AlertView: View {
    let baby: Baby  // Baby object containing health-related entries

    // Computed property to determine unique recent alerts within the past week
    private var recentAlerts: [String] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        var alerts: Set<String> = [] // Using Set to store unique alerts

        // Check for stool-related medical alerts
        if baby.stoolEntries.stoolEntries.contains(where: { $0.dateTime >= oneWeekAgo && $0.medicalAlert }) {
            alerts.insert("⚠️ Stool Issue Detected")
        }

        // Check for dehydration risk from wet diaper entries
        if baby.wetDiaperEntries.wetDiaperEntries.contains(where: { $0.dateTime >= oneWeekAgo && $0.dehydrationAlert }) {
            alerts.insert("⚠️ Dehydration Risk")
        }

        // Check for dehydration symptoms from dehydration checks
        if baby.dehydrationChecks.dehydrationChecks.contains(where: { $0.dateTime >= oneWeekAgo && $0.dehydrationAlert }) {
            alerts.insert("⚠️ Dehydration Symptoms")
        }

        return Array(alerts) // Convert Set back to an Array for SwiftUI rendering
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if recentAlerts.isEmpty {
                // Display message when no alerts are present
                Text("✅ No alerts in the past week")
                    .foregroundColor(.white)
                    .font(.headline)

                // Motivational message for parents
                Text("Great job taking care of your little one! 💕 Keep up the amazing work!")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
            } else {
                // Display unique alerts
                ForEach(recentAlerts, id: \.self) { alert in
                    Text(alert)
                        .font(.headline)
                        .foregroundColor(.white) // Ensures contrast with red background
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(recentAlerts.isEmpty ? Color.green.opacity(0.8) : Color.red.opacity(0.8)) // Green if no alerts, red otherwise
        )
        .frame(height: 120) // Fixed height for consistent UI
    }
}
