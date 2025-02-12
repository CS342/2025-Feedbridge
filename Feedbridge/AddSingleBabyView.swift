//
//  AddSingleBabyView.swift
//  Feedbridge
//
//  Created by Calvin Xu on 2/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import SwiftUI

struct AddSingleBabyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FeedbridgeStandard.self) private var standard
    
    @State private var babyName = ""
    @State private var dateOfBirth = Date()
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var onSave: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Baby's Name", text: $babyName)
                DatePicker(
                    "Date of Birth",
                    selection: $dateOfBirth,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            .navigationTitle("Add Baby")
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
                            await saveBaby()
                        }
                    }
                    .disabled(babyName.isEmpty)
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveBaby() async {
        do {
            try await standard.addBabies(babies: [Baby(name: babyName, dateOfBirth: dateOfBirth)])
            onSave?()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
}

#Preview {
    AddSingleBabyView()
        .previewWith(standard: FeedbridgeStandard()) {}
}
