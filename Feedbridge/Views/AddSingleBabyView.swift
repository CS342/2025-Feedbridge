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
    @State private var existingBabies: [Baby] = []
    @State private var isLoading = true

    var onSave: ((Baby) -> Void)?

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Add Baby")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .alert("Error", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
                .task {
                    await loadExistingBabies()
                }
        }
    }
    
    private var contentView: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                formContent
            }
        }
    }
    
    private var formContent: some View {
        Form {
            VStack(alignment: .leading, spacing: 4) {
                TextField("Baby's Name", text: $babyName)
                if hasDuplicateName {
                    Text("This name is already taken")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            DatePicker(
                "Date of Birth",
                selection: $dateOfBirth,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                Task {
                    await saveBaby()
                }
            }
            .disabled(babyName.isEmpty || isLoading || hasDuplicateName)
        }
    }

    private var hasDuplicateName: Bool {
        !babyName.isEmpty && existingBabies.contains { $0.name.lowercased() == babyName.lowercased() }
    }

    private func loadExistingBabies() async {
        do {
            existingBabies = try await standard.getBabies()
        } catch {
            errorMessage = "Failed to load existing babies: \(error.localizedDescription)"
            showAlert = true
        }
        isLoading = false
    }

    private func saveBaby() async {
        guard !hasDuplicateName else {
            errorMessage = "A baby with this name already exists"
            showAlert = true
            return
        }

        do {
            let baby = Baby(name: babyName, dateOfBirth: dateOfBirth)
            try await standard.addBabies(babies: [baby])
            onSave?(baby)
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
