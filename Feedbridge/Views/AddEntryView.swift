//
//  AddEntryView.swift
//  Feedbridge
//
//  Created by Calvin Xu on 2/25/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
// swiftlint:disable closure_body_length
// swiftlint:disable file_length

import FirebaseFirestore
import SwiftUI

// MARK: - [ Supporting Types ]

/// Represents the user's choice for which kind of entry we're creating.
enum EntryKind: String, CaseIterable, Identifiable, Equatable {
    case weight = "Weight"
    case feeding = "Feed"
    case wetDiaper = "Void"
    case stool = "Stool"
    case dehydration = "Dehydration"

    var id: String { rawValue }
}

/// Represents the weight units
enum WeightUnit: String, CaseIterable {
    case kilograms = "Kilograms"
    case poundsOunces = "Pounds & Ounces"
}

// MARK: - [ Main View: AddEntryView ]

struct AddEntryView: View {
    // MARK: [ Subtype ]

    enum FieldFocus {
        case weightKg, weightLb, weightOz
        case feedTime, feedVolume
    }

    // MARK: [ Environment & Dependencies ]

    @Environment(\.dismiss) private var dismiss
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.colorScheme) private var colorScheme

    /// Shared real-time view model for the dashboard
    var viewModel: DashboardViewModel

    // MARK: [ State for Babies Selection ]

    @AppStorage(UserDefaults.selectedBabyIdKey) private var selectedBabyId: String?
    @State private var hasBabies = false

    // MARK: [ Shared Entry Data ]

    /// Global date/time for all entry kinds
    @State private var date = Date()

    /// Which kind of entry the user wants to create
    @State private var entryKind: EntryKind?

    // MARK: [ Weight Entry Fields ]

    @State private var weightUnit: WeightUnit = .kilograms
    @State private var weightKg: String = ""
    @State private var weightLb: String = ""
    @State private var weightOz: String = ""

    // MARK: [ Feeding Entry Fields ]

    @State private var feedType: FeedType = .directBreastfeeding
    @State private var milkType: MilkType = .breastmilk
    @State private var feedTimeInMinutes: String = ""
    @State private var feedVolumeInML: String = ""

    // MARK: [ Wet Diaper Fields ]

    @State private var wetVolume: DiaperVolume = .light
    @State private var wetColor: WetDiaperColor = .yellow

    // MARK: [ Stool Fields ]

    @State private var stoolVolume: StoolVolume = .light
    @State private var stoolColor: StoolColor = .brown

    // MARK: [ Dehydration Fields ]

    @State private var poorSkinElasticity: Bool = false
    @State private var dryMucousMembranes: Bool = false

    // MARK: [ Focus Management ]

    @FocusState private var focusedField: FieldFocus?

    // MARK: [ Feedback Messages ]

    /// Error from server or Firestore operations.
    @State private var serverErrorMessage: String?

    /// Controls whether a "Success" banner is shown after saving
    @State private var showSuccessMessage: Bool = false

    // MARK: [ Computed Form Validation ]

    /// Returns a tuple with:
    /// 1) `complete`: true if user has entered all required fields for this entry kind,
    /// 2) `error`: a string if the user entered something invalid (but not empty).
    private var formCheck: (complete: Bool, error: String?) {
        guard let kind = entryKind else {
            // No kind selected => cannot proceed
            return (false, nil)
        }

        switch kind {
        case .weight:
            if weightUnit == .kilograms {
                // If empty => form incomplete, no error displayed
                if weightKg.isEmpty {
                    return (false, nil)
                }
                // If user typed something invalid => show an error
                guard let weightKg = Double(weightKg), weightKg > 0 else {
                    return (true, "Invalid weight (kg) value.")
                }
                // Valid
                return (true, nil)
            } else {
                // If both fields empty => form incomplete, no error
                if weightLb.isEmpty, weightOz.isEmpty {
                    return (false, nil)
                }
                // If user typed something invalid => error
                guard
                    let weightLb = Double(weightLb), weightLb >= 0,
                    let weightOz = Double(weightOz), weightOz >= 0,
                    weightLb > 0 || weightOz > 0
                else {
                    return (true, "Invalid weight (lb/oz) values.")
                }
                // Valid
                return (true, nil)
            }

        case .feeding:
            if feedType == .directBreastfeeding {
                // If empty => incomplete
                if feedTimeInMinutes.isEmpty {
                    return (false, nil)
                }
                // If non-empty invalid => error
                guard let minutes = Int(feedTimeInMinutes), minutes > 0 else {
                    return (true, "Invalid feed time (minutes).")
                }
                // Valid
                _ = minutes
                return (true, nil)
            } else {
                // If empty => incomplete
                if feedVolumeInML.isEmpty {
                    return (false, nil)
                }
                // If non-empty invalid => error
                guard let volume = Int(feedVolumeInML), volume > 0 else {
                    return (true, "Invalid bottle volume (ml).")
                }
                // Valid
                _ = volume
                return (true, nil)
            }

        case .wetDiaper:
            // No numeric input => always complete, no error
            return (true, nil)

        case .stool:
            // Always complete, no error
            return (true, nil)

        case .dehydration:
            // Always complete, no error
            return (true, nil)
        }
    }

    /// Whether all required fields have been filled with valid data
    private var isInputValid: Bool {
        let (complete, error) = formCheck
        return complete && (error == nil)
    }

    /// The local (validation) error to show, if any
    private var validationError: String? {
        let (complete, error) = formCheck
        // Show the error if the form is "complete enough" but invalid
        // and `error` is non-nil. If incomplete => no error shown.
        guard complete else {
            return nil
        }
        return error
    }

    // MARK: [ View ]

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    if viewModel.baby == nil {
                        VStack(spacing: 16) {
                            VStack {
                                Text("No babies found")
                                    .font(.headline)
                                Text("Please add a baby in Settings before adding entries.")
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 20) {
                            // Success banner
                            if showSuccessMessage {
                                Text("Entry saved successfully!")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .zIndex(1)
                            }

                            // Date/time
                            dateTimeSection
                                .padding(.horizontal)

                            // Entry kind list
                            entryKindSection

                            // The dynamic fields for the selected entry type
                            if let kind = entryKind {
                                dynamicFields(for: kind)
                                    .id("ActiveSection")
                                    .padding()
                                    .background(.thinMaterial)
                                    .cornerRadius(12)
                                    .padding()
                                    .transition(
                                        .asymmetric(
                                            insertion: .move(edge: .bottom)
                                                .combined(with: .opacity),
                                            removal: .opacity.animation(.easeOut(duration: 0.15))
                                        )
                                    )
                            }

                            // Validation error from local input
                            if let error = validationError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }

                            // Confirm button
                            if entryKind != nil {
                                confirmButton
                                    .padding(.horizontal)
                            }

                            // Server error if Firestore fails
                            if let serverError = serverErrorMessage {
                                Text(serverError)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }

                            Spacer(minLength: 80)
                        }
                        .padding(.vertical)
                        .onChange(of: entryKind) {
                            // No param => new iOS 17 style
                            withAnimation(.easeInOut(duration: 0.15)) {
                                proxy.scrollTo("ActiveSection", anchor: .center)
                            }
                            serverErrorMessage = nil
                        }
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                .navigationTitle("Add Entry")
                // Attempt to find or set a baby if none is selected
                .task {
                    if selectedBabyId == nil {
                        do {
                            let babies = try await standard.getBabies()
                            if !babies.isEmpty {
                                selectedBabyId = babies.first?.id
                                UserDefaults.standard.selectedBabyId = selectedBabyId
                            }
                        } catch {
                            serverErrorMessage = "Failed to load babies: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
        // Clear server error if user changes something:
        .onChange(of: date) {
            serverErrorMessage = nil
        }
        .onChange(of: weightUnit) {
            serverErrorMessage = nil
        }
        .onChange(of: weightKg) {
            serverErrorMessage = nil
        }
        .onChange(of: weightLb) {
            serverErrorMessage = nil
        }
        .onChange(of: weightOz) {
            serverErrorMessage = nil
        }
        .onChange(of: feedType) {
            serverErrorMessage = nil
        }
        .onChange(of: milkType) {
            serverErrorMessage = nil
        }
        .onChange(of: feedTimeInMinutes) {
            serverErrorMessage = nil
        }
        .onChange(of: feedVolumeInML) {
            serverErrorMessage = nil
        }
        .onChange(of: wetVolume) {
            serverErrorMessage = nil
        }
        .onChange(of: wetColor) {
            serverErrorMessage = nil
        }
        .onChange(of: stoolVolume) {
            serverErrorMessage = nil
        }
        .onChange(of: stoolColor) {
            serverErrorMessage = nil
        }
        .onChange(of: poorSkinElasticity) {
            serverErrorMessage = nil
        }
        .onChange(of: dryMucousMembranes) {
            serverErrorMessage = nil
        }
    }
}

// MARK: - [ Extension: Subviews ]

extension AddEntryView {
    /// A date/time picker that can be adjusted
    private var dateTimeSection: some View {
        VStack(alignment: .leading) {
            Text("Hi! It is now:")
                .font(.headline)
            DatePicker(
                "Select Date & Time",
                selection: $date,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
        }
    }

    /// A vertical list of entry kinds
    private var entryKindSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What entry would you like to enter?")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(EntryKind.allCases) { kind in
                    Button {
                        withAnimation {
                            resetAllFields()
                            entryKind = kind
                        }
                    } label: {
                        HStack {
                            Text(kind.rawValue)
                                .font(entryKind == kind ? .body.bold() : .body)
                                .foregroundColor(
                                    entryKind == kind
                                        ? accentColor(for: kind)
                                        : .primary
                                )
                            Spacer()
                            if entryKind == kind {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding()
                        .background(
                            entryKind == kind
                                ? accentColor(for: kind).opacity(0.15)
                                : (colorScheme == .dark
                                    ? Color.white.opacity(0.15)
                                    : Color.white)
                        )
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - [ Dynamic Subviews ]

    private var weightEntryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "scalemass.fill")
                    .accessibilityLabel("Scale")
                    .font(.title3)
                    .foregroundColor(accentColor(for: .weight))

                Text("Weight Details")
                    .font(.title3.bold())
                    .foregroundColor(accentColor(for: .weight))

                Spacer()
            }

            Picker("Unit", selection: $weightUnit) {
                ForEach(WeightUnit.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)

            if weightUnit == .kilograms {
                TextField("Kilograms", text: $weightKg)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .weightKg)
                    .onSubmit {
                        focusedField = .weightLb
                    }
                    .textFieldStyle(.roundedBorder)
                    .onAppear {
                        focusedField = .weightKg
                    }
            } else {
                HStack {
                    TextField("Pounds", text: $weightLb)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .weightLb)
                        .onSubmit {
                            focusedField = .weightOz
                        }
                        .textFieldStyle(.roundedBorder)

                    TextField("Ounces", text: $weightOz)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .weightOz)
                        .textFieldStyle(.roundedBorder)
                        .onAppear {
                            focusedField = .weightLb
                        }
                }
            }
        }
    }

    private var feedingEntryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .accessibilityLabel("Flame")
                    .font(.title3)
                    .foregroundColor(accentColor(for: .feeding))

                Text("Feed Details")
                    .font(.title3.bold())
                    .foregroundColor(accentColor(for: .feeding))

                Spacer()
            }

            Picker("Feeding Type", selection: $feedType) {
                Text("Direct Breastfeeding").tag(FeedType.directBreastfeeding)
                Text("Bottle").tag(FeedType.bottle)
            }
            .pickerStyle(.segmented)

            if feedType == .directBreastfeeding {
                TextField("Feed time (minutes)", text: $feedTimeInMinutes)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .feedTime)
                    .textFieldStyle(.roundedBorder)
                    .onAppear { focusedField = .feedTime }
            } else {
                TextField("Bottle volume (ml)", text: $feedVolumeInML)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .feedVolume)
                    .textFieldStyle(.roundedBorder)
                    .onAppear { focusedField = .feedVolume }

                Picker("Milk Type", selection: $milkType) {
                    Text("Breastmilk").tag(MilkType.breastmilk)
                    Text("Formula").tag(MilkType.formula)
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var wetDiaperView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "drop.fill")
                    .accessibilityLabel("Wet Diaper Drop")
                    .font(.title3)
                    .foregroundColor(accentColor(for: .wetDiaper))

                Text("Void Details")
                    .font(.title3.bold())
                    .foregroundColor(accentColor(for: .wetDiaper))

                Spacer()
            }

            Picker("Volume", selection: $wetVolume) {
                Text("Light").tag(DiaperVolume.light)
                Text("Medium").tag(DiaperVolume.medium)
                Text("Heavy").tag(DiaperVolume.heavy)
            }
            .pickerStyle(.segmented)

            Picker("Color", selection: $wetColor) {
                Text("Yellow").tag(WetDiaperColor.yellow)
                Text("Pink").tag(WetDiaperColor.pink)
                Text("Red").tag(WetDiaperColor.redTinged)
            }
            .pickerStyle(.segmented)
        }
    }

    private var stoolView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "drop.fill")
                    .accessibilityLabel("Stool Drop")
                    .font(.title3)
                    .foregroundColor(.brown)

                Text("Stool Details")
                    .font(.title3.bold())
                    .foregroundColor(.brown)

                Spacer()
            }

            Picker("Volume", selection: $stoolVolume) {
                Text("Light").tag(StoolVolume.light)
                Text("Medium").tag(StoolVolume.medium)
                Text("Heavy").tag(StoolVolume.heavy)
            }
            .pickerStyle(.segmented)

            Picker("Color", selection: $stoolColor) {
                Text("Black").tag(StoolColor.black)
                Text("Dark Green").tag(StoolColor.darkGreen)
                Text("Green").tag(StoolColor.green)
                Text("Brown").tag(StoolColor.brown)
                Text("Yellow").tag(StoolColor.yellow)
                Text("Beige").tag(StoolColor.beige)
            }
            .pickerStyle(.segmented)
        }
    }

    private var dehydrationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .accessibilityLabel("Dehydration Heart")
                    .font(.title3)
                    .foregroundColor(accentColor(for: .dehydration))

                Text("Dehydration Details")
                    .font(.title3.bold())
                    .foregroundColor(accentColor(for: .dehydration))

                Spacer()
            }

            Toggle("Poor Skin Elasticity", isOn: $poorSkinElasticity)
            Toggle("Dry Mucous Membranes", isOn: $dryMucousMembranes)
        }
    }

    private var confirmButton: some View {
        Button {
            Task {
                await saveEntry()
            }
        } label: {
            Text("Confirm")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        // Disable if no baby is selected or if there's an error or incomplete fields
        .disabled(!isInputValid || selectedBabyId == nil)
    }
}

// MARK: - [ Extension: Actions & Helpers ]

extension AddEntryView {
    private func resetAllFields() {
        weightKg = ""
        weightLb = ""
        weightOz = ""

        feedType = .directBreastfeeding
        milkType = .breastmilk
        feedTimeInMinutes = ""
        feedVolumeInML = ""

        wetVolume = .light
        wetColor = .yellow

        stoolVolume = .light
        stoolColor = .brown

        poorSkinElasticity = false
        dryMucousMembranes = false
    }

    private func saveEntry() async {
        // Double-check we have a baby selected
        guard let babyId = selectedBabyId else {
            return
        }

        // Double-check valid inputs
        if !isInputValid {
            // Should never happen if confirmButton is disabled, but just in case:
            return
        }

        do {
            switch entryKind {
            case .weight:
                try await handleWeightEntry(babyId: babyId)
            case .feeding:
                try await handleFeedingEntry(babyId: babyId)
            case .wetDiaper:
                try await handleWetDiaperEntry(babyId: babyId)
            case .stool:
                try await handleStoolEntry(babyId: babyId)
            case .dehydration:
                try await handleDehydrationEntry(babyId: babyId)
            case .none:
                return
            }

            // On success, reset fields
            resetAllFields()
            entryKind = nil
            date = Date()

            // Show success banner temporarily
            withAnimation(.easeIn(duration: 0.3)) {
                showSuccessMessage = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showSuccessMessage = false
                }
            }
        } catch {
            // E.g. Firestore or network error
            serverErrorMessage = error.localizedDescription
        }
    }

    private func handleWeightEntry(babyId: String) async throws {
        if weightUnit == .kilograms {
            let weightKg = Double(weightKg) ?? 0
            let entry = WeightEntry(kilograms: weightKg, dateTime: date)
            try await standard.addWeightEntry(entry, toBabyWithId: babyId)
        } else {
            let weightLb = Double(weightLb) ?? 0
            let weightOz = Double(weightOz) ?? 0
            let entry = WeightEntry(pounds: Int(weightLb), ounces: Int(weightOz), dateTime: date)
            try await standard.addWeightEntry(entry, toBabyWithId: babyId)
        }
    }

    private func handleFeedingEntry(babyId: String) async throws {
        if feedType == .directBreastfeeding {
            let minutes = Int(feedTimeInMinutes) ?? 0
            let entry = FeedEntry(directBreastfeeding: minutes, dateTime: date)
            try await standard.addFeedEntry(entry, toBabyWithId: babyId)
        } else {
            let volume = Int(feedVolumeInML) ?? 0
            let entry = FeedEntry(bottle: volume, milkType: milkType, dateTime: date)
            try await standard.addFeedEntry(entry, toBabyWithId: babyId)
        }
    }

    private func handleWetDiaperEntry(babyId: String) async throws {
        let entry = WetDiaperEntry(dateTime: date, volume: wetVolume, color: wetColor)
        try await standard.addWetDiaperEntry(entry, toBabyWithId: babyId)
    }

    private func handleStoolEntry(babyId: String) async throws {
        let entry = StoolEntry(dateTime: date, volume: stoolVolume, color: stoolColor)
        try await standard.addStoolEntry(entry, toBabyWithId: babyId)
    }

    private func handleDehydrationEntry(babyId: String) async throws {
        let entry = DehydrationCheck(
            dateTime: date,
            poorSkinElasticity: poorSkinElasticity,
            dryMucousMembranes: dryMucousMembranes
        )
        try await standard.addDehydrationCheck(entry, toBabyWithId: babyId)
    }
}

// MARK: - [ Extension: Dynamic Fields + Accent ]

extension AddEntryView {
    /// Decides which subview to show for the selected entryKind
    @ViewBuilder
    private func dynamicFields(for kind: EntryKind) -> some View {
        switch kind {
        case .weight:
            weightEntryView
        case .feeding:
            feedingEntryView
        case .wetDiaper:
            wetDiaperView
        case .stool:
            stoolView
        case .dehydration:
            dehydrationView
        }
    }

    /// Returns a color for each entry kind
    private func accentColor(for kind: EntryKind) -> Color {
        switch kind {
        case .weight:
            return .indigo
        case .feeding:
            return .pink
        case .wetDiaper:
            return .orange
        case .stool:
            return .brown
        case .dehydration:
            return .green
        }
    }
}

// MARK: - [ SwiftUI Preview ]

#Preview {
    AddEntryView(viewModel: DashboardViewModel())
        .previewWith(standard: FeedbridgeStandard()) {}
}
