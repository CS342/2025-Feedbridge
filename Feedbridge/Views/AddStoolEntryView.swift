//
//  StoolEntryView.swift
//  Feedbridge
//
//  Created by Shamit Surana on 2/8/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import FirebaseFirestore
import SwiftUI

struct AddStoolEntryView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss
    
    let babyId: String
    
    @State private var stoolVolume: StoolVolume = .light
    @State private var stoolColor: StoolColor = .yellow
    @State private var date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // swiftlint: disable closure_body_length
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date & Time", selection: $date)
                }
                
                Section(header: Text("Stool Volume")) {
                    Picker("Stool Volume", selection: $stoolVolume) {
                        Text("Light").tag(StoolVolume.light)
                        Text("Medium").tag(StoolVolume.medium)
                        Text("Heavy").tag(StoolVolume.heavy)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Stool Color")) {
                    Picker("Stool Color", selection: $stoolColor) {
                        Text("Yellow").tag(StoolColor.yellow)
                        Text("Black").tag(StoolColor.black)
                        Text("Brown").tag(StoolColor.brown)
                        Text("Dark Green").tag(StoolColor.darkGreen)
                        Text("Green").tag(StoolColor.green)
                        Text("Beige").tag(StoolColor.beige)
                    }
                    .pickerStyle(.wheel)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
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
                            await saveFeedEntry()
                        }
                    }
                    .disabled(isLoading)
                }
            }
        }
    }
    
    private func saveFeedEntry() async {
        isLoading = true
        errorMessage = nil
        
        let entry = StoolEntry(dateTime: date, volume: stoolVolume, color: stoolColor)
        
        do {
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
