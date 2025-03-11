//
//  DehydrationCharts.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// Grid displaying dehydration alerts over the past 5 days.
struct AlertGridView: View {
    var entries: [DehydrationCheck]

    private var pastWeekAlerts: [(date: String, hasAlert: Bool)] {
        let today = Calendar.current.startOfDay(for: Date())
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: today) ?? today

        let filteredChecks = entries.filter { $0.dateTime >= fiveDaysAgo }

        let grouped = Dictionary(grouping: filteredChecks) { check in
            Calendar.current.startOfDay(for: check.dateTime)
        }

        return (0..<5).compactMap { offset in
            if let date = Calendar.current.date(byAdding: .day, value: offset, to: fiveDaysAgo) {
                let dateString = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
                let hasAlert = grouped[date]?.contains(where: { $0.dehydrationAlert }) ?? false
                return (dateString, hasAlert)
            }
            return nil
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(pastWeekAlerts, id: \.date) { data in
                Text(data.date)
                    .font(.caption)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(data.hasAlert ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                    )
                    .foregroundColor(.white)
            }
        }
    }
}

struct DehydrationSummaryView: View {
    var entries: [DehydrationCheck]
    let babyId: String
    
    // Optional viewModel for real-time data
    var viewModel: DashboardViewModel?
    
    private var currentEntries: [DehydrationCheck] {
        // Use viewModel data if available, otherwise fall back to passed entries
        if let baby = viewModel?.baby {
            return baby.dehydrationChecks.dehydrationChecks
        }
        return entries
    }
    
    var body: some View {
        NavigationLink(
            destination: DehydrationView(entries: currentEntries, babyId: babyId, viewModel: viewModel)
        ) {
            summaryCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func summaryCard() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .opacity(0.8)
            
            VStack {
                header()
                Spacer()
                AlertGridView(entries: entries) // Embedded struct usage
                    .padding(.bottom, 16)
            }
        }
        .frame(height: 130)
    }
    
    /// Creates the header view for the summary card.
    private func header() -> some View {
        HStack {
            Image(systemName: "heart.fill")
                .accessibilityLabel("Heart icon")
                .font(.title3)
                .foregroundColor(.green)
            
            Text("Dehydration Symptoms")
                .font(.title3.bold())
                .foregroundColor(.green)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .accessibilityLabel("Next page")
                .foregroundColor(.gray)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding()
    }
}
