//
//  AddStoolEntryView.swift
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

struct AddStoolEntryView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss
    
    let babyId: String
    
    @State private var volume = StoolVolume.medium
    @State private var color = StoolColor.brown
    @State private var date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Volume", selection: $volume) {
                        Text("Light").tag(StoolVolume.light)
                        Text("Medium").tag(StoolVolume.medium)
                        Text("Heavy").tag(StoolVolume.heavy)
                    }
                    
                    Picker("Color", selection: $color) {
                        Text("Black").tag(StoolColor.black)
                        Text("Dark Green").tag(StoolColor.darkGreen)
                        Text("Green").tag(StoolColor.green)
                        Text("Brown").tag(StoolColor.brown)
                        Text("Yellow").tag(StoolColor.yellow)
                        Text("Beige").tag(StoolColor.beige)
                    }
                    
                    DatePicker("Date & Time", selection: $date)
                }
                
                if color == .beige {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("This color may indicate a medical concern")
                                .foregroundColor(.red)
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
            .navigationTitle("Add Stool Entry")
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
            let entry = StoolEntry(
                dateTime: date,
                volume: volume,
                color: color
            )
            
            try await standard.addStoolEntry(entry, toBabyWithId: babyId)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    AddStoolEntryView(babyId: "preview")
        .previewWith(standard: FeedbridgeStandard()) {}
}
