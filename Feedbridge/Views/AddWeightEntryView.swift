//
//  AddWeightEntryView.swift
//  Feedbridge
//
//  Created by Calvin Xu on 2/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
// swiftlint:disable closure_body_length

import SwiftUI

struct AddWeightEntryView: View {
    private enum WeightUnit: String, CaseIterable {
        case kilograms = "Kilograms"
        case poundsOunces = "Pounds & Ounces"
    }

    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss

    let babyId: String

    @State private var weightUnit = WeightUnit.kilograms
    @State private var kilograms = ""
    @State private var pounds = ""
    @State private var ounces = ""
    @State private var date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Unit", selection: $weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }

                    if weightUnit == .kilograms {
                        TextField("Weight in Kilograms", text: $kilograms)
                            .keyboardType(.decimalPad)
                    } else {
                        TextField("Pounds", text: $pounds)
                            .keyboardType(.numberPad)
                        TextField("Ounces", text: $ounces)
                            .keyboardType(.numberPad)
                    }

                    DatePicker("Date & Time", selection: $date)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Weight Entry")
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
                            await saveWeight()
                        }
                    }
                    .disabled(!isValid || isLoading)
                }
            }
        }
    }

    private var isValid: Bool {
        if weightUnit == .kilograms {
            return Double(kilograms) != nil
        } else {
            return Int(pounds) != nil && Int(ounces) != nil
        }
    }

    private func saveWeight() async {
        isLoading = true
        errorMessage = nil

        do {
            let entry: WeightEntry
            if weightUnit == .kilograms {
                guard let kilosWeight = Double(kilograms) else {
                    return
                }
                entry = WeightEntry(kilograms: kilosWeight, dateTime: date)
            } else {
                guard let poundsWeight = Int(pounds),
                      let ouncesWeight = Int(ounces)
                else {
                    return
                }
                entry = WeightEntry(pounds: poundsWeight, ounces: ouncesWeight, dateTime: date)
            }

            try await standard.addWeightEntry(entry, toBabyWithId: babyId)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    AddWeightEntryView(babyId: "preview")
        .previewWith(standard: FeedbridgeStandard()) {}
}
