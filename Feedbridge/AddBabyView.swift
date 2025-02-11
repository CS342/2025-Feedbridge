//
//  AddBabyView.swift
//  Feedbridge
//
//  Created by Calvin Xu on 2/4/25.
//
// swiftlint:disable closure_body_length

import FirebaseFirestore
import SpeziOnboarding
import SpeziViews
import SwiftUI

struct AddBabyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    
    @State private var nextId = 0
    @State private var babies: [(id: Int, baby: Baby)] = [(id: 0, baby: Baby(name: "", dateOfBirth: Date()))]
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack(spacing: 24) {
                    OnboardingTitleView(
                        title: "Add Your Baby",
                        subtitle: "Please enter your baby's information"
                    )
                    
                    ForEach(babies, id: \.id) { baby in
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
                    
                    Button {
                        nextId += 1
                        babies.append((id: nextId, baby: Baby(name: "", dateOfBirth: Date())))
                    } label: {
                        Label("Add Another Baby", systemImage: "plus.circle.fill")
                    }
                    .padding(.vertical)
                }
            },
            actionView: {
                OnboardingActionsView(
                    "Continue",
                    action: {
                        Task {
                            await saveBabies()
                        }
                    }
                )
                .disabled(babies.contains(where: { $0.baby.name.isEmpty }))
            }
        )
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveBabies() async {
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
