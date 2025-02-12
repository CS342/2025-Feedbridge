//
//  FeedEntryView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 2/8/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import SwiftUI
import FirebaseFirestore

struct AddFeedEntryView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss
    
    let babyId: String
    
    @State private var feedType: FeedType = .directBreastfeeding
    @State private var milkType: MilkType = .breastmilk
    @State private var feedTimeInMinutes: Int = 0
    @State private var feedVolumeInML: Double = 0.0
    @State private var date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date & Time", selection: $date)
                }
                
                Section(header: Text("Feeding Details")) {
                    Picker("Feeding Method", selection: $feedType) {
                        Text("Direct Breastfeeding").tag(FeedType.directBreastfeeding)
                        Text("Bottle").tag(FeedType.bottle)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if feedType == .bottle {
                        Picker("Milk Type", selection: $milkType) {
                            Text("Breastmilk").tag(MilkType.breastmilk)
                            Text("Formula").tag(MilkType.formula)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Stepper(value: $feedVolumeInML, in: 0...500, step: 10) {
                            Text("Volume: \(feedVolumeInML, specifier: "%.0f") mL")
                        }
                    } else {
                        Stepper(value: $feedTimeInMinutes, in: 0...60, step: 1) {
                            Text("Duration: \(feedTimeInMinutes) min")
                        }
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Feed Entry")
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
        
        let entry: FeedEntry
        if feedType == .directBreastfeeding {
            entry = FeedEntry(directBreastfeeding: feedTimeInMinutes, dateTime: date)
        } else {
            entry = FeedEntry(bottle: feedVolumeInML, milkType: milkType, dateTime: date)
        }
        
        do {
            try await standard.addFeedEntry(entry, toBabyWithId: babyId)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    AddFeedEntryView(babyId: "preview")
        .previewWith(standard: FeedbridgeStandard()) {}
}
