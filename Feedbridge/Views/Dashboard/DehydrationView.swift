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
    
    /// List of dehydration check entries sorted by date, showing symptoms and alert status.
    private var dehydrationChecksList: some View {
        List(currentEntries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text(entry.dateTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(entry.dehydrationAlert ? "⚠️ Alert" : "✅ Normal")
                    .font(.headline)
                    .foregroundColor(entry.dehydrationAlert ? .red : .green)
                    
                HStack {
                    dehydrationSymptomView(title: "Skin Elasticity", isPresent: entry.poorSkinElasticity)
                    Spacer()
                    dehydrationSymptomView(title: "Dry Mucous Membranes", isPresent: entry.dryMucousMembranes)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            print("Delete dehydration check entry with id: \(entry.id ?? "")")
                            print("Baby: \(babyId)")
                            try await standard.deleteDehydrationCheck(babyId: babyId, entryId: entry.id ?? "")
                            // Remove from local state
                            self.entries.removeAll { $0.id == entry.id }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    /// Creates a view showing a specific dehydration symptom.
    private func dehydrationSymptomView(title: String, isPresent: Bool) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer(minLength: 2)
            Image(systemName: isPresent ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .accessibilityLabel(isPresent ? "Alert present" : "Normal")
                .foregroundColor(isPresent ? .red : .green)
        }
    }
}
