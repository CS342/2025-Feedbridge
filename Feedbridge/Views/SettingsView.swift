// BabyDebugDisplayView.swift
//  Feedbridge
//
//  Created by Calvin Xu on 2/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
// swiftlint:disable file_length

import SwiftUI

private struct BasicInfoSection: View {
    let baby: Baby
    @Binding var weightUnitPreference: WeightUnit

    var body: some View {
        Section("Basic Info") {
            LabeledContent("Name", value: baby.name)
            LabeledContent("Date of Birth", value: baby.dateOfBirth.formatted())
            LabeledContent("Age", value: "\(baby.ageInMonths) months")
        }
    }
}

private struct FeedEntriesSection: View {
    let entries: [FeedEntry]
    var babyId: String
    var standard: FeedbridgeStandard
    @State private var refreshID = UUID()  // For forcing view refresh

    var body: some View {
        Section("Feed Entries") {
            ForEach(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
                VStack(alignment: .leading) {
                    Text(entry.dateTime.formatted())
                        .font(.caption)
                    Text("Type: \(entry.feedType.rawValue)")
                    if entry.feedType == .bottle {
                        Text("Milk Type: \(entry.milkType?.rawValue ?? "N/A")")
                        if let volume = entry.feedVolumeInML {
                            Text("Amount: \(volume)ml")
                        }
                    } else if let minutes = entry.feedTimeInMinutes {
                        Text("Duration: \(minutes) minutes")
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            if let entryId = entry.id {
                                try await standard.deleteFeedEntry(babyId: babyId, entryId: entryId)
                                // Force view refresh
                                refreshID = UUID()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .id(refreshID)  // Force refresh when an item is deleted
        }
    }
}

private struct WeightEntriesSection: View {
    let entries: [WeightEntry]
    @Binding var weightUnitPreference: WeightUnit
    var babyId: String
    var standard: FeedbridgeStandard
    @State private var refreshID = UUID()  // For forcing view refresh

    var body: some View {
        Section("Weight Entries") {
            ForEach(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.dateTime.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(
                        "\(weightUnitPreference == .kilograms ? entry.asKilograms.value : entry.asPounds.value, specifier: "%.2f") \(weightUnitPreference == .kilograms ? "kg" : "lb")"
                    )
                    .font(.body)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            if let entryId = entry.id {
                                try await standard.deleteWeightEntry(babyId: babyId, entryId: entryId)
                                // Force view refresh
                                refreshID = UUID()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .id(refreshID)  // Force refresh when an item is deleted
        }
    }
}

private struct StoolEntriesSection: View {
    let entries: [StoolEntry]
    var babyId: String
    var standard: FeedbridgeStandard
    @State private var refreshID = UUID()  // For forcing view refresh

    var body: some View {
        Section("Stool Entries") {
            ForEach(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
                VStack(alignment: .leading) {
                    Text(entry.dateTime.formatted())
                        .font(.caption)
                    Text("Volume: \(entry.volume.rawValue)")
                    Text("Color: \(entry.color.rawValue)")
                    if entry.medicalAlert {
                        Text("⚠️ Medical Alert")
                            .foregroundColor(.red)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            if let entryId = entry.id {
                                try await standard.deleteStoolEntry(babyId: babyId, entryId: entryId)
                                // Force view refresh
                                refreshID = UUID()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .id(refreshID)  // Force refresh when an item is deleted
        }
    }
}

private struct WetDiaperEntriesSection: View {
    let entries: [WetDiaperEntry]
    var babyId: String
    var standard: FeedbridgeStandard
    @State private var refreshID = UUID()  // For forcing view refresh

    var body: some View {
        Section("Void Entries") {
            ForEach(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
                VStack(alignment: .leading) {
                    Text(entry.dateTime.formatted())
                        .font(.caption)
                    Text("Volume: \(entry.volume.rawValue)")
                    Text("Color: \(entry.color.rawValue)")
                    if entry.dehydrationAlert {
                        Text("⚠️ Dehydration Alert")
                            .foregroundColor(.red)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            if let entryId = entry.id {
                                try await standard.deleteWetDiaperEntry(babyId: babyId, entryId: entryId)
                                // Force view refresh
                                refreshID = UUID()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .id(refreshID)  // Force refresh when an item is deleted
        }
    }
}

private struct DehydrationChecksSection: View {
    let checks: [DehydrationCheck]
    var babyId: String
    var standard: FeedbridgeStandard
    @State private var refreshID = UUID()  // For forcing view refresh

    var body: some View {
        Section("Dehydration Checks") {
            ForEach(checks.sorted(by: { $0.dateTime > $1.dateTime })) { check in
                VStack(alignment: .leading) {
                    Text(check.dateTime.formatted())
                        .font(.caption)
                    Text("Poor Skin Elasticity: \(check.poorSkinElasticity ? "Yes" : "No")")
                    Text("Dry Mucous Membranes: \(check.dryMucousMembranes ? "Yes" : "No")")
                    if check.dehydrationAlert {
                        Text("⚠️ Dehydration Alert")
                            .foregroundColor(.red)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            if let checkId = check.id {
                                try await standard.deleteDehydrationCheck(babyId: babyId, entryId: checkId)
                                // Force view refresh
                                refreshID = UUID()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .id(refreshID)  // Force refresh when an item is deleted
        }
    }
}

struct HealthDetailsView: View {
    // Use the shared viewModel instead of a direct baby reference
    var viewModel: DashboardViewModel
    @Binding var weightUnitPreference: WeightUnit
    @AppStorage(UserDefaults.selectedBabyIdKey) private var selectedBabyId: String?
    @State private var isRefreshing = false
    @Environment(FeedbridgeStandard.self) private var standard
    @State private var refreshID = UUID()  // For forcing view refresh

    var body: some View {
        Group {
            if let baby = viewModel.baby {
                List {
                    FeedEntriesSection(
                        entries: baby.feedEntries.feedEntries, babyId: baby.id ?? "", standard: standard
                    )
                    WeightEntriesSection(
                        entries: baby.weightEntries.weightEntries,
                        weightUnitPreference: $weightUnitPreference,
                        babyId: baby.id ?? "",
                        standard: standard
                    )
                    StoolEntriesSection(
                        entries: baby.stoolEntries.stoolEntries, babyId: baby.id ?? "", standard: standard
                    )
                    WetDiaperEntriesSection(
                        entries: baby.wetDiaperEntries.wetDiaperEntries,
                        babyId: baby.id ?? "",
                        standard: standard
                    )
                    DehydrationChecksSection(
                        checks: baby.dehydrationChecks.dehydrationChecks,
                        babyId: baby.id ?? "",
                        standard: standard
                    )
                }
                .id(refreshID)  // Force refresh when data changes
                .refreshable {
                    await refreshData()
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Health Details")
        .onAppear {
            // Ensure we have the latest data when the view appears
            if !isRefreshing {
                Task {
                    await refreshData()
                }
            }
        }
        .onChange(of: viewModel.baby) { _, _ in
            // When the baby data changes in the viewModel, update the refreshID
            refreshID = UUID()
        }
    }

    private func refreshData() async {
        isRefreshing = true

        // Stop and restart the listener to refresh all data
        viewModel.stopListening()
        if let id = selectedBabyId {
            viewModel.startListening(babyId: id)
        }

        // Add a small delay to ensure the UI shows the refresh indicator
        try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds

        // Update the refreshID to force a view refresh
        refreshID = UUID()

        isRefreshing = false
    }
}

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
