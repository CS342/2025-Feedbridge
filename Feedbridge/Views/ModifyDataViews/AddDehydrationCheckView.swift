//
//  DehydrationView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 2/8/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import FirebaseFirestore
import SwiftUI

struct AddDehydrationCheckView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss

    let babyId: String

    @State private var poorSkinElasticity = false
    @State private var dryMucousMembranes = false
    @State private var date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date & Time", selection: $date)
                }

                Section(header: Text("Dehydration Symptoms")) {
                    Toggle("Poor Skin Elasticity", isOn: $poorSkinElasticity)
                    Toggle("Dry Mucous Membranes", isOn: $dryMucousMembranes)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Dehydration Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveDehydrationCheck()
                        }
                    }
                    .disabled(isLoading)
                }
            }
        }
    }

    private func saveDehydrationCheck() async {
        isLoading = true
        errorMessage = nil

        let entry = DehydrationCheck(
            dateTime: date,
            poorSkinElasticity: poorSkinElasticity,
            dryMucousMembranes: dryMucousMembranes
        )

        do {
            try await standard.addDehydrationCheck(entry, toBabyWithId: babyId)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    AddDehydrationCheckView(babyId: "preview")
        .previewWith(standard: FeedbridgeStandard()) {}
}
