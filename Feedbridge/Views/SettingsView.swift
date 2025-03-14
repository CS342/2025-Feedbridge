// BabyDebugDisplayView.swift
//  Feedbridge
//
//  Created by Calvin Xu on 2/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct Settings: View {
    @Environment(FeedbridgeStandard.self) private var standard

    // Use the shared viewModel passed from HomeView
    var viewModel: DashboardViewModel

    @State private var babies: [Baby] = []
    @State private var isLoadingBabies = false
    @State private var babiesErrorMessage: String?
    @State private var weightUnitPreference: WeightUnit = UserDefaults.standard.weightUnitPreference
    @State private var showingDeleteAlert = false
    @AppStorage(UserDefaults.selectedBabyIdKey) private var selectedBabyId: String?

    @ViewBuilder private var content: some View {
        Group {
            if viewModel.isLoading || isLoadingBabies {
                ProgressView()
            } else if let error = viewModel.errorMessage ?? babiesErrorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                babyList
            }
        }
    }

    @ViewBuilder private var babyList: some View {
        List {
            Section("Select baby") {
                babyPicker
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }
            if let baby = viewModel.baby {
                BasicInfoSection(baby: baby, weightUnitPreference: $weightUnitPreference)
                Section("Preferences") {
                    Toggle(
                        "Use Kilograms",
                        isOn: Binding(
                            get: { weightUnitPreference == .kilograms },
                            set: {
                                weightUnitPreference = $0 ? .kilograms : .poundsOunces
                                UserDefaults.standard.weightUnitPreference = weightUnitPreference
                            }
                        )
                    )
                }
                Section("Baby Summary") {
                    NavigationLink("Health Details") {
                        HealthDetailsView(viewModel: viewModel, weightUnitPreference: $weightUnitPreference)
                    }
                }
                deleteButton
            } else {
                Text("No baby selected")
                    .foregroundColor(.secondary)
            }
        }
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Settings")
                .task {
                    await loadBabies()
                }
                .onChange(of: selectedBabyId) { _, newId in
                    // When the selected baby changes in other views, we should update our list
                    if newId != nil && viewModel.baby?.id != newId {
                        Task {
                            await loadBabies()
                        }
                    }
                }
                .onChange(of: viewModel.baby) { _, _ in
                    // When the baby data changes in the viewModel, refresh our UI
                    Task {
                        await loadBabies()
                    }
                }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteAlert = true
        } label: {
            Image(systemName: "trash").accessibilityLabel("Delete Baby")
            Text("Delete Baby")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .listRowBackground(Color.clear)
        .confirmationDialog(
            Text("Are you sure you want to delete this baby?"),
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await deleteBaby()
                }
            }
        }
    }
}

// MARK: - Extensions

extension UserDefaults {
    static let selectedBabyIdKey = "selectedBabyId"
    static let weightUnitPreference = "weightUnitPreference"

    var selectedBabyId: String? {
        get { string(forKey: Self.selectedBabyIdKey) }
        set { setValue(newValue, forKey: Self.selectedBabyIdKey) }
    }

    var weightUnitPreference: WeightUnit {
        get {
            guard let value = string(forKey: Self.weightUnitPreference),
                  let unit = WeightUnit(rawValue: value)
            else {
                return .kilograms  // Default value
            }
            return unit
        }
        set {
            set(newValue.rawValue, forKey: Self.weightUnitPreference)
        }
    }
}

// MARK: - Helper Methods
extension Settings {
    @ViewBuilder private var babyPicker: some View {
        Menu {
            ForEach(babies) { baby in
                Button {
                    selectedBabyId = baby.id
                    UserDefaults.standard.selectedBabyId = baby.id
                } label: {
                    HStack {
                        Text(baby.name)
                        Spacer()
                        if baby.id == selectedBabyId {
                            Image(systemName: "checkmark")
                                .accessibilityLabel("Selected")
                        }
                    }
                }
            }
            Divider()
            NavigationLink("Add New Baby") {
                AddSingleBabyView(onSave: { newBaby in
                    UserDefaults.standard.selectedBabyId = newBaby.id
                    selectedBabyId = newBaby.id
                    Task {
                        await loadBabies()
                    }
                })
            }
        } label: {
            HStack {
                Image(systemName: "person.crop.circle")
                    .accessibilityLabel("Baby icon")
                Text(babies.first(where: { $0.id == selectedBabyId })?.name ?? "Select Baby")
                Image(systemName: "chevron.down")
                    .accessibilityLabel("Menu dropdown")
            }
            .padding()
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(8)
        }
    }

    private func deleteBaby() async {
        guard let babyId = selectedBabyId else {
            return
        }

        do {
            try await standard.deleteBaby(id: babyId)
            selectedBabyId = nil
            UserDefaults.standard.selectedBabyId = nil
            await loadBabies()
        } catch {
            babiesErrorMessage = "Failed to delete baby: \(error.localizedDescription)"
        }
    }

    private func loadBabies() async {
        isLoadingBabies = true
        babiesErrorMessage = nil

        do {
            babies = try await standard.getBabies()
            if let savedId = UserDefaults.standard.selectedBabyId,
               babies.contains(where: { $0.id == savedId }) {
                selectedBabyId = savedId
            } else {
                selectedBabyId = babies.first?.id
                UserDefaults.standard.selectedBabyId = selectedBabyId
            }
        } catch {
            babiesErrorMessage = "Failed to load babies: \(error.localizedDescription)"
        }

        isLoadingBabies = false
    }
}

#Preview("Settings") {
    Settings(viewModel: DashboardViewModel())
        .previewWith(standard: FeedbridgeStandard()) {}
}

#Preview("Health Details") {
    HealthDetailsView(viewModel: DashboardViewModel(), weightUnitPreference: .constant(.kilograms))
        .previewWith(standard: FeedbridgeStandard()) {}
}
