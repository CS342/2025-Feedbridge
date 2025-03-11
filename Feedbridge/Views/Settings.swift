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

private struct BabyDetailsList: View {
    let baby: Baby
    @Binding var weightUnitPreference: WeightUnit

    var body: some View {
        FeedEntriesSection(entries: baby.feedEntries.feedEntries)
        WeightEntriesSection(entries: baby.weightEntries.weightEntries, weightUnitPreference: $weightUnitPreference)
        StoolEntriesSection(entries: baby.stoolEntries.stoolEntries)
        WetDiaperEntriesSection(entries: baby.wetDiaperEntries.wetDiaperEntries)
        DehydrationChecksSection(checks: baby.dehydrationChecks.dehydrationChecks)
    }
}

private struct BasicInfoSection: View {
    let baby: Baby
    @Binding var weightUnitPreference: WeightUnit

    var body: some View {
        Section("Basic Info") {
            LabeledContent("Name", value: baby.name)
            //            LabeledContent("ID", value: baby.id ?? "N/A")
            LabeledContent("Date of Birth", value: baby.dateOfBirth.formatted())
            LabeledContent("Age", value: "\(baby.ageInMonths) months")
            //            if let weight = baby.currentWeight {
            //                LabeledContent("Current Weight", value: String(format: "%.2f", weightUnitPreference == .kilograms ? weight.asKilograms.value : weight.asPounds.value) + " \(weightUnitPreference == .kilograms ? "kg" : "lb")")
            //            }
            //            LabeledContent("Has Active Alerts", value: baby.hasActiveAlerts ? "Yes" : "No")
        }
    }
}

private struct FeedEntriesSection: View {
    let entries: [FeedEntry]

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
            }
        }
    }
}

private struct WeightEntriesSection: View {
    let entries: [WeightEntry]
    @Binding var weightUnitPreference: WeightUnit

    var body: some View {
        Section("Weight Entries") {
            ForEach(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.dateTime.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(weightUnitPreference == .kilograms ? entry.asKilograms.value : entry.asPounds.value, specifier: "%.2f") \(weightUnitPreference == .kilograms ? "kg" : "lb")")
                        .font(.body)
                }
            }
        }
    }
}

private struct StoolEntriesSection: View {
    let entries: [StoolEntry]

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
            }
        }
    }
}

private struct WetDiaperEntriesSection: View {
    let entries: [WetDiaperEntry]

    var body: some View {
        Section("Wet Diaper Entries") {
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
            }
        }
    }
}

private struct DehydrationChecksSection: View {
    let checks: [DehydrationCheck]

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
            }
        }
    }
}

struct HealthDetailsView: View {
    let baby: Baby
    @Binding var weightUnitPreference: WeightUnit

    var body: some View {
        List {
            FeedEntriesSection(entries: baby.feedEntries.feedEntries)
            WeightEntriesSection(entries: baby.weightEntries.weightEntries, weightUnitPreference: $weightUnitPreference)
            StoolEntriesSection(entries: baby.stoolEntries.stoolEntries)
            WetDiaperEntriesSection(entries: baby.wetDiaperEntries.wetDiaperEntries)
            DehydrationChecksSection(checks: baby.dehydrationChecks.dehydrationChecks)
        }
        .navigationTitle("Health Details")
    }
}

struct Settings: View {
    @Environment(FeedbridgeStandard.self) private var standard

    @State private var curBaby: Baby?
    @State private var babies: [Baby] = []
    @State private var selectedBabyId: String?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingDeleteAlert = false
    @State private var weightUnitPreference: WeightUnit = UserDefaults.standard.weightUnitPreference

    @ViewBuilder private var content: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let error = errorMessage {
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
            if let curBaby {
                BasicInfoSection(baby: curBaby, weightUnitPreference: $weightUnitPreference)
                Section("Preferences") {
                    Toggle("Use Kilograms", isOn: Binding(
                        get: { weightUnitPreference == .kilograms },
                        set: {
                            weightUnitPreference = $0 ? .kilograms : .poundsOunces
                            UserDefaults.standard.weightUnitPreference = weightUnitPreference
                        }
                    ))
                }
                Section("Baby Summary") {
                    NavigationLink("Health Details") {
                        HealthDetailsView(baby: curBaby, weightUnitPreference: $weightUnitPreference)
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
                    await loadBaby()
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
                  let unit = WeightUnit(rawValue: value) else {
                return .kilograms // Default value
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
                    Task {
                        await loadBaby(needLoading: false)
                    }
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
                    curBaby = newBaby
                    UserDefaults.standard.selectedBabyId = newBaby.id
                    selectedBabyId = newBaby.id
                    print("New baby added: \(newBaby)")
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
            await loadBaby()
        } catch {
            errorMessage = "Failed to delete baby: \(error.localizedDescription)"
        }
    }

    private func loadBaby(needLoading: Bool = true) async {
        guard let babyId = selectedBabyId else {
            curBaby = nil
            return
        }

        if needLoading {
            isLoading = true
        }
        errorMessage = nil

        do {
            curBaby = try await standard.getBaby(id: babyId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadBabies() async {
        isLoading = true
        errorMessage = nil

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
            errorMessage = "Failed to load babies: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
