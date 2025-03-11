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

/// Represents the user’s choice for which kind of entry we’re creating.
enum EntryKind: String, CaseIterable, Identifiable {
  case weight = "Weight"
  case feeding = "Feed"
  case wetDiaper = "Void"
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
enum WeightUnit: String, CaseIterable {
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
  @AppStorage(UserDefaults.selectedBabyIdKey) private var selectedBabyId: String?

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
      }
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
            DatePicker("Select Date & Time", selection: $date, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
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
                                .font(entryKind == kind
                                      ? .body.bold()
                                      : .body)
                                .foregroundColor(entryKind == kind
                                                 ? accentColor(for: kind)
                                                 : .black)
                            Spacer()
                            if entryKind == kind {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding()
                        .background(
                            entryKind == kind
                                ? accentColor(for: kind).opacity(0.15)
                                : Color.gray.opacity(0.15)
                        )
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }


  // MARK: - Weight UI

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

  // MARK: - Stool UI

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

  // MARK: - Dehydration UI

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
    
    private func handleWeightEntry(babyId: String) async throws {
        if let weightKg = Double(weightKg), weightKg > 0 {
          let entry = WeightEntry(kilograms: weightKg, dateTime: date)
          try await standard.addWeightEntry(entry, toBabyWithId: babyId)
        } else if let weightLb = Double(weightLb), weightLb >= 0,
          let weightOz = Double(weightOz), weightOz >= 0,
          weightLb > 0 || weightOz > 0 {
          let pounds = Int(weightLb)
          let ounces = Int(weightOz)
          let entry = WeightEntry(pounds: pounds, ounces: ounces, dateTime: date)
          try await standard.addWeightEntry(entry, toBabyWithId: babyId)
        } else {
          throw ValidationError("Invalid weight values")
        }
    }
    
    private func handleFeedingEntry(babyId: String) async throws {
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

  private func saveEntry() async {
    guard let babyId = selectedBabyId else {
      errorMessage = "Please select a baby."
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
// MARK: - [ Helper Methods ]
/// A function that returns a specific background color depending on the entry kind
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
    private func accentColor(for kind: EntryKind) -> Color {
        switch kind {
        case .weight:
            return Color.indigo
        case .feeding:
            return Color.pink
        case .wetDiaper:
            return Color.orange
        case .stool:
            return Color.brown
        case .dehydration:
            return Color.green
        }
    }
}

// MARK: - [ Preview Provider ]
#Preview {
  AddEntryView()
    .previewWith(standard: FeedbridgeStandard()) {}
}
