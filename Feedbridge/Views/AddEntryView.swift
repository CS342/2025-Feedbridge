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
// swiftlint:disable function_body_length

import FirebaseFirestore
import SwiftUI

// MARK: - [ Supporting Types ]

/// Represents the user’s choice for which kind of entry we’re creating.
enum EntryKind: String, CaseIterable, Identifiable {
  case weight = "Weight"
  case feeding = "Feeding"
  case wetDiaper = "Wet Diaper"
  case stool = "Stool"
  case dehydration = "Dehydration"

  var id: String { rawValue }
}

/// A simple LocalizedError for validation
struct ValidationError: LocalizedError {
  var errorDescription: String?
  init(_ message: String) {
    errorDescription = message
  }
}

/// Represents the weight units
private enum WeightUnit: String, CaseIterable {
    case kilograms = "Kilograms"
    case poundsOunces = "Pounds & Ounces"
}

// MARK: - [ Main Type ]

struct AddEntryView: View {
  // MARK: [ Subtype ]

  enum FieldFocus {
    case weightKg, weightLb, weightOz
    case feedTime, feedVolume
    // Add more as needed for automatic focusing
  }

  // MARK: [ Instance Properties ]

  // Environment
  @Environment(\.dismiss) private var dismiss
  @Environment(FeedbridgeStandard.self) private var standard

  // Babies
  @State private var babies: [Baby] = []
  @State private var selectedBabyId: String?

  // Global date/time
  @State private var date = Date()

  // Current entry kind
  @State private var entryKind: EntryKind?

  // Weight Entry Fields
  @State private var weightUnit: WeightUnit = .kilograms
  @State private var weightKg: String = ""
  @State private var weightLb: String = ""
  @State private var weightOz: String = ""

  // Feed Entry Fields
  @State private var feedType: FeedType = .directBreastfeeding
  @State private var milkType: MilkType = .breastmilk
  @State private var feedTimeInMinutes: String = ""
  @State private var feedVolumeInML: String = ""

  // Wet Diaper Fields
  @State private var wetVolume: DiaperVolume = .light
  @State private var wetColor: WetDiaperColor = .yellow

  // Stool Fields
  @State private var stoolVolume: StoolVolume = .light
  @State private var stoolColor: StoolColor = .brown

  // Dehydration Fields
  @State private var poorSkinElasticity: Bool = false
  @State private var dryMucousMembranes: Bool = false

  // Focus management
  @FocusState private var focusedField: FieldFocus?

  // Error handling
  @State private var errorMessage: String?
  @State private var showSuccessMessage: Bool = false
    
  // MARK: [ View Lifecycle Method ]

  var body: some View {
    NavigationView {
      ScrollViewReader { proxy in
        ScrollView {
          VStack(alignment: .leading, spacing: 20) {
            // Baby picker
            babyPickerSection
              .padding(.horizontal)

            // Date/Time
            dateTimeSection
              .padding(.horizontal)

            // Entry kind (vertical list)
            entryKindSection

            // Dynamic section: show only if the user picked an entry kind
            if let kind = entryKind {
              dynamicFields(for: kind)
                .id("ActiveSection")
                .padding()
                .background(.thinMaterial)
                .cornerRadius(12)
                .padding()
                // Faster, more distinct insertion/removal transitions
                .transition(
                  .asymmetric(
                    insertion: .move(edge: .bottom)
                      .combined(with: .opacity),
                    removal: .opacity.animation(.easeOut(duration: 0.15))
                  )
                )
                .animation(.easeInOut(duration: 0.15), value: kind)
            }

            // Confirm button
            if entryKind != nil {
              confirmButton
                .padding(.horizontal)
            }
              
            
            Text("Success saving")
              .foregroundColor(.green)
              .padding()
              .background(Color.green.opacity(0.1))
              .cornerRadius(8)
              .transition(.opacity)
              .padding(.horizontal)
              .opacity(showSuccessMessage ? 1 : 0)

            // Error message
            if let error = errorMessage {
              Text(error)
                .foregroundColor(.red)
                .padding(.horizontal)
            }

            // Add some space at the bottom for ergonomic scrolling
            Spacer(minLength: 80)
          }
          .padding(.vertical)
          // Use the new onChange signature for iOS 17, fallback otherwise
          .applyOnChange(of: $entryKind) { _, _ in
            // Center the dynamic fields if the user selects a new entry kind
            withAnimation(.easeInOut(duration: 0.15)) {
              proxy.scrollTo("ActiveSection", anchor: .center)
            }
          }
        }
        .navigationTitle("Add Entry")
        .onAppear {
          Task {
            await loadBabies()
          }
        }
      }
    }
  }
}

// MARK: - [ Extension: Subviews ]

extension AddEntryView {
  /// Baby picker section
  @ViewBuilder private var babyPickerSection: some View {
    babyPicker
  }

  /// A date/time picker that can be adjusted
  private var dateTimeSection: some View {
    VStack(alignment: .leading) {
      Text("Hi! It is now:")
        .font(.headline)
      DatePicker("Select Date & Time", selection: $date)
        .labelsHidden()
    }
  }

  /// A vertical list of entry-kinds to choose from
  private var entryKindSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("What entry would you like to enter?")
        .font(.headline)

      // A simple vertical list of selectable items:
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
                .font(.body)
              Spacer()
              if entryKind == kind {
                Image(systemName: "checkmark")
                  .foregroundColor(.blue)
              }
            }
            .padding()
            .background(
              entryKind == kind
                ? Color.blue.opacity(0.2)
                : Color.gray.opacity(0.15)
            )
            .cornerRadius(8)
          }
        }
      }
    }
    .padding(.horizontal)
  }

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

  // MARK: - Weight UI

  private var weightEntryView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Enter Weight")
        .font(.headline)
        
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
              .textFieldStyle(.roundedBorder).onAppear {
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
                    .onSubmit {
                        // done
                    }
                    .textFieldStyle(.roundedBorder)
                
                    .onAppear {
                        focusedField = .weightLb
                    }
            }
        }
    }
  }

  // MARK: - Feeding UI

  private var feedingEntryView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Feeding Details")
        .font(.headline)

      Picker("Feeding Type", selection: $feedType) {
        Text("Direct Breastfeeding").tag(FeedType.directBreastfeeding)
        Text("Bottle").tag(FeedType.bottle)
      }
      .pickerStyle(.segmented)

      if feedType == .directBreastfeeding {
        TextField("Feed time (minutes)", text: $feedTimeInMinutes)
          .keyboardType(.numberPad)
          .focused($focusedField, equals: .feedTime)
          .onSubmit {
            // done
          }
          .textFieldStyle(.roundedBorder)
          .onAppear { focusedField = .feedTime }
      } else {
        TextField("Bottle volume (ml)", text: $feedVolumeInML)
          .keyboardType(.numberPad)
          .focused($focusedField, equals: .feedVolume)
          .onSubmit {
            // done
          }
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

  // MARK: - Wet Diaper UI

  private var wetDiaperView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Wet Diaper")
        .font(.headline)

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

  // MARK: - Stool UI

  private var stoolView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Stool")
        .font(.headline)

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

  // MARK: - Dehydration UI

  private var dehydrationView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Dehydration Check")
        .font(.headline)

      Toggle("Poor Skin Elasticity", isOn: $poorSkinElasticity)
      Toggle("Dry Mucous Membranes", isOn: $dryMucousMembranes)
    }
  }

  // MARK: - Confirm Button

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
    .disabled(selectedBabyId == nil)
  }
}

// MARK: - [ Extension: Actions ]

extension AddEntryView {
  private func loadBabies() async {
    do {
      let loadedBabies = try await standard.getBabies()
      babies = loadedBabies

      // Restore previously selected from UserDefaults, if any
      if let stored = UserDefaults.standard.selectedBabyId,
        loadedBabies.map(\.id).contains(stored)
      {
        selectedBabyId = stored
      }
    } catch {
      errorMessage = error.localizedDescription
    }
  }

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
    guard let babyId = selectedBabyId else {
      errorMessage = "Please select a baby."
      return
    }

    do {
      switch entryKind {
      case .weight:
        if let weightKg = Double(weightKg), weightKg > 0 {
          let entry = WeightEntry(kilograms: weightKg, dateTime: date)
          try await standard.addWeightEntry(entry, toBabyWithId: babyId)
        } else if let weightLb = Double(weightLb), weightLb >= 0,
          let weightOz = Double(weightOz), weightOz >= 0,
          weightLb > 0 || weightOz > 0
        {
          let pounds = Int(weightLb)
          let ounces = Int(weightOz)
          let entry = WeightEntry(pounds: pounds, ounces: ounces, dateTime: date)
          try await standard.addWeightEntry(entry, toBabyWithId: babyId)
        } else {
          throw ValidationError("Invalid weight values")
        }

      case .feeding:
        if feedType == .directBreastfeeding {
          guard let minutes = Int(feedTimeInMinutes), minutes > 0 else {
            throw ValidationError("Invalid feed time")
          }
          let entry = FeedEntry(directBreastfeeding: minutes, dateTime: date)
          try await standard.addFeedEntry(entry, toBabyWithId: babyId)
        } else {
          guard let volume = Int(feedVolumeInML), volume > 0 else {
            throw ValidationError("Invalid feed volume")
          }
          let entry = FeedEntry(bottle: volume, milkType: milkType, dateTime: date)
          try await standard.addFeedEntry(entry, toBabyWithId: babyId)
        }

      case .wetDiaper:
        let entry = WetDiaperEntry(dateTime: date, volume: wetVolume, color: wetColor)
        try await standard.addWetDiaperEntry(entry, toBabyWithId: babyId)

      case .stool:
        let entry = StoolEntry(dateTime: date, volume: stoolVolume, color: stoolColor)
        try await standard.addStoolEntry(entry, toBabyWithId: babyId)

      case .dehydration:
        let entry = DehydrationCheck(
          dateTime: date,
          poorSkinElasticity: poorSkinElasticity,
          dryMucousMembranes: dryMucousMembranes
        )
        try await standard.addDehydrationCheck(entry, toBabyWithId: babyId)

      case .none:
        return
      }

      // On success, reset
      resetAllFields()
      entryKind = nil
      date = Date()
        
      showSuccessMessage = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        showSuccessMessage = false
      }
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}

// MARK: - [ Extension: Baby Picker ]

extension AddEntryView {
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
        AddSingleBabyView(onSave: {
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
      .foregroundColor(.primary)
      .padding()
      .frame(maxWidth: .infinity)
      .background(Color(.systemBackground))
      .cornerRadius(8)
    }
  }
}

// MARK: - [ Extension: iOS 17 onChange Back-Compat ]

extension View {
  /// A helper to handle the new iOS 17 two-parameter onChange signature,
  /// while gracefully falling back to the older one-parameter version on earlier iOS.
  @ViewBuilder
  func applyOnChange<Value: Equatable>(
    of binding: Binding<Value>,
    _ action: @escaping (Value, Value) -> Void
  ) -> some View {
    if #available(iOS 17, *) {
      self.onChange(of: binding.wrappedValue) { oldValue, newValue in
        action(oldValue, newValue)
      }
    } else {
      // Fallback for older iOS: we only have the "newValue" version
      onChange(of: binding.wrappedValue) { newValue in
        // We don't have the old value, so just pass the same value twice.
        action(newValue, newValue)
      }
    }
  }
}

// MARK: - [ Preview Provider ]

#Preview {
  AddEntryView()
    .previewWith(standard: FeedbridgeStandard()) {}
}
