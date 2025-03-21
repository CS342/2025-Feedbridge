//
//  AddBabyView.swift
//  Feedbridge
//
//  Created by Calvin Xu on 2/4/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import SpeziOnboarding
import SpeziViews
import SwiftUI

// Supporting view that's used by the main view
struct BabyFormRow: View {
    let baby: (id: Int, baby: Baby)
    @Binding var babies: [(id: Int, baby: Baby)]
    let existingBabies: [Baby]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Baby's Name", text: Binding(
                get: { baby.baby.name },
                set: { newValue in
                    if let index = babies.firstIndex(where: { $0.id == baby.id }) {
                        babies[index].baby.name = newValue
                    }
                }
            ))
            .textFieldStyle(.roundedBorder)

            if !baby.baby.name.isEmpty && isDuplicateName(baby.baby.name) {
                Text("This name is already taken")
                    .foregroundColor(.red)
                    .font(.caption)
            }

            DatePicker(
                "Date of Birth",
                selection: Binding(
                    get: { baby.baby.dateOfBirth },
                    set: { newValue in
                        if let index = babies.firstIndex(where: { $0.id == baby.id }) {
                            babies[index].baby.dateOfBirth = newValue
                        }
                    }
                ),
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private func isDuplicateName(_ name: String) -> Bool {
        let lowercaseName = name.lowercased()

        if existingBabies.contains(where: { $0.name.lowercased() == lowercaseName }) {
            return true
        }

        return babies.contains(where: { $0.id != baby.id && $0.baby.name.lowercased() == lowercaseName })
    }
}

// Main view
struct AddBabyView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    @State private var nextId = 0
    @State private var babies: [(id: Int, baby: Baby)] = [(id: 0, baby: Baby(name: "", dateOfBirth: Date()))]
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var existingBabies: [Baby] = []
    @State private var isLoading = true
    
    private var hasDuplicateNames: Bool {
        // Check for duplicates within new babies
        let newBabyNames = babies.map { $0.baby.name.lowercased() }
        if Set(newBabyNames).count != newBabyNames.count {
            return true
        }

        // Check against existing babies
        let existingNames = Set(existingBabies.map { $0.name.lowercased() })
        return !newBabyNames.filter { !$0.isEmpty }
            .allSatisfy { !existingNames.contains($0) }
    }
    
    private var babyFormContent: some View {
        VStack(spacing: 24) {
            OnboardingTitleView(
                title: "Add Your Baby",
                subtitle: "Please enter your baby's information"
            )
            
            ForEach(babies, id: \.id) { baby in
                BabyFormRow(
                    baby: baby,
                    babies: $babies,
                    existingBabies: existingBabies
                )
            }
            
            Button {
                nextId += 1
                babies.append((id: nextId, baby: Baby(name: "", dateOfBirth: Date())))
            } label: {
                Label("Add Another Baby", systemImage: "plus.circle.fill")
            }
            .padding(.vertical)
        }
    }

    var body: some View {
        OnboardingView(
            contentView: { createContentView() },
            actionView: { createActionView() }
        )
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .task {
            await loadExistingBabies()
        }
    }
    
    private func createContentView() -> some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                babyFormContent
            }
        }
        .padding()
    }
    
    private func createActionView() -> some View {
        VStack {
            OnboardingActionsView(
                "Continue",
                action: {
                    Task {
                        await saveBabies()
                    }
                }
            )
            .disabled(babies.contains(where: { $0.baby.name.isEmpty }) || hasDuplicateNames || isLoading)

            Button("Add babies later") {
                onboardingNavigationPath.nextStep()
            }
            .buttonStyle(.automatic)
            .padding(.top, 8)
        }
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

    private func saveBabies() async {
        guard !hasDuplicateNames else {
            errorMessage = "Each baby must have a unique name"
            showAlert = true
            return
        }

        do {
            try await standard.addBabies(babies: babies.map(\.baby))
            onboardingNavigationPath.nextStep()
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
}

#Preview {
    OnboardingStack {
        AddBabyView()
    }
}
