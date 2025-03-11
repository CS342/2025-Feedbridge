//
//  AddWetDiaperEntryView.swift
//  Feedbridge
//
//  Created by Shamit Surana on 2/8/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
// swiftlint:disable closure_body_length

import SwiftUI

struct AddWetDiaperEntryView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss

    let babyId: String

    @State private var volume = DiaperVolume.medium
    @State private var color = WetDiaperColor.yellow
    @State private var date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date & Time", selection: $date)

                    Picker("Volume", selection: $volume) {
                        Text("Light").tag(DiaperVolume.light)
                        Text("Medium").tag(DiaperVolume.medium)
                        Text("Heavy").tag(DiaperVolume.heavy)
                    }

                    Picker("Color", selection: $color) {
                        Text("Yellow").tag(WetDiaperColor.yellow)
                        Text("Pink").tag(WetDiaperColor.pink)
                        Text("Red-Tinged").tag(WetDiaperColor.redTinged)
                    }
                }
                if color == .pink || color == .redTinged {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .accessibilityLabel("Warning")
                            Text("This color may indicate dehydration")
                                .foregroundColor(.red)
                                .accessibilityLabel("This color may indicate dehydration")
                        }
                    }
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Wet Diaper Entry")
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
                            await saveEntry()
                        }
                    }
                    .disabled(isLoading)
                }
            }
        }
    }

    private func saveEntry() async {
        isLoading = true
        errorMessage = nil

        do {
            let entry = WetDiaperEntry(
                dateTime: date,
                volume: volume,
                color: color
            )

            try await standard.addWetDiaperEntry(entry, toBabyWithId: babyId)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    AddWetDiaperEntryView(babyId: "preview")
        .previewWith(standard: FeedbridgeStandard()) {}
}
