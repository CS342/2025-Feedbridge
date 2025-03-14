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

struct AlertData {
    let date: String
    let hasData: Bool
    let hasAlert: Bool
}
/// Grid displaying dehydration alerts over the past 5 days.
struct AlertGridView: View {
    /// Static date formatter for efficiency
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    var entries: [DehydrationCheck]

    private var pastWeekAlerts: [AlertData] {
        let today = Calendar.current.startOfDay(for: Date())
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: today) ?? today

        let filteredChecks = entries.filter { $0.dateTime >= fiveDaysAgo }

        let grouped = Dictionary(grouping: filteredChecks) { check in
            Calendar.current.startOfDay(for: check.dateTime)
        }

        return (0..<5).compactMap { offset in
            guard let date = Calendar.current.date(byAdding: .day, value: offset, to: fiveDaysAgo) else {
                return nil
            }

            let dateString = Self.dateFormatter.string(from: date)
            let hasData = grouped[date]?.isEmpty == false
            let hasAlert = grouped[date]?.contains(where: { $0.dehydrationAlert }) ?? false

            return AlertData(date: dateString, hasData: hasData, hasAlert: hasAlert)
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
                            .fill(alertColor(for: data))
                    )
                    .foregroundColor(.white)
            }
        }
    }

    /// Function to determine background color
    private func alertColor(for data: AlertData) -> Color {
        if !data.hasData {
            return Color.gray.opacity(0.8)
        } else if data.hasAlert {
            return Color.red.opacity(0.8)
        } else {
            return Color.green.opacity(0.8)
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

    private var lastEntry: DehydrationCheck? {
        currentEntries.max(by: { $0.dateTime < $1.dateTime })
    }

    var body: some View {
        NavigationLink(
            destination: DehydrationView(entries: currentEntries, babyId: babyId, viewModel: viewModel)
        ) {
            summaryCard()
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier("dehydrationSummaryView")
    }

    private func summaryCard() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .opacity(0.8)

            VStack {
                header()
                if lastEntry != nil {
                    Spacer()
                    AlertGridView(entries: entries)
                        .frame(height: 40)
                } else {
                    Text("No data added")
                        .foregroundColor(.gray)
                        .padding()
                }
                Spacer()
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
