//
//  DehydrationView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// View displaying dehydration check entries with detailed symptoms and an alert grid.
struct DehydrationView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.presentationMode) var presentationMode
    @State var entries: [DehydrationCheck]
    let babyId: String

    // Optional viewModel for real-time data
    var viewModel: DashboardViewModel?

    private var currentEntries: [DehydrationCheck] {
        if let baby = viewModel?.baby {
            return baby.dehydrationChecks.dehydrationChecks
        }
        return entries
    }
    
    var body: some View {
        NavigationStack {
            AlertGridView(entries: currentEntries)
                .padding()
            dehydrationChecksList
        }
        .navigationTitle("Dehydration Symptoms")
    }
    
    private var dehydrationChecksList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.dateTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    if entry.dehydrationAlert {
                        Text("⚠️ Alert")
                            .font(.headline)
                            .foregroundColor(.red)
                    } else {
                        Text("✅ Normal")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }

                Divider()

                HStack {
                    dehydrationSymptomView(title: "Skin Elasticity", isPresent: entry.poorSkinElasticity)
                    Spacer()
                    dehydrationSymptomView(title: "Dry Mucous Membranes", isPresent: entry.dryMucousMembranes)
                }
            }
            .padding(.vertical, 6)
        }
    }

    /// Creates a view showing a specific dehydration symptom.
    private func dehydrationSymptomView(title: String, isPresent: Bool) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer(minLength: 8)
            Image(systemName: isPresent ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .accessibilityLabel("Alert")
                .foregroundColor(isPresent ? .red : .green)
        }
    }
}
