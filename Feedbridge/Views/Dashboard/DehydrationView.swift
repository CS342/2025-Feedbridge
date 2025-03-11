//
//  DehydrationView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/10/25.
//

import SwiftUI

/// View displaying dehydration check entries with detailed symptoms and an alert grid.
struct DehydrationView: View {
    var entries: [DehydrationCheck]

    var body: some View {
        NavigationStack {
            VStack {
                AlertGridView(entries: entries)
                    .padding()

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
            .navigationTitle("Dehydration Checks")
        }
    }

    /// Creates a view showing a specific dehydration symptom.
    private func dehydrationSymptomView(title: String, isPresent: Bool) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer(minLength: 8)
            Image(systemName: isPresent ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundColor(isPresent ? .red : .green)
        }
    }
}
