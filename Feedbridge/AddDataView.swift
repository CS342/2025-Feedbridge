//
//  AddDataView.swift
//  Feedbridge
//
//  Created by Shamit Surana on 2/8/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount
import SwiftUI

struct AddDataView: View {
    // MARK: - Type Definitions
    private enum DataEntrySheet: Identifiable {
        case weight
        
        var id: Int {
            switch self {
            case .weight: return 1
            }
        }
    }
    
    struct DataEntry: Identifiable {
        let id = UUID()
        let label: String
        let imageName: String
        let action: () -> Void
    }
    
    // MARK: - Properties
    @Environment(Account.self) private var account: Account?
    @Environment(FeedbridgeStandard.self) private var standard
    @Binding var presentingAccount: Bool
    
    @State private var babies: [Baby] = []
    @State private var selectedBabyId: String?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var presentedSheet: DataEntrySheet?
    
    private var dataEntries: [DataEntry] {
        [
            DataEntry(
                label: "Feed Entry",
                imageName: "flame.fill",
                action: { /* logic to handle feed entry */ }
            ),
            DataEntry(
                label: "Wet Diaper Entry",
                imageName: "drop.fill",
                action: { /* logic to handle wet diaper entry */ }
            ),
            DataEntry(
                label: "Stool Entry",
                imageName: "plus.circle.fill",
                action: { /* logic to handle stool entry */ }
            ),
            DataEntry(
                label: "Dehydration Check",
                imageName: "exclamationmark.triangle.fill",
                action: { /* logic to handle dehydration check */ }
            ),
            DataEntry(
                label: "Weight Entry",
                imageName: "scalemass.fill",
                action: { presentedSheet = .weight }
            )
        ]
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    mainContent
                }
            }
            .navigationTitle("Add Data")
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .task {
                await loadBabies()
            }
        }
        .sheet(item: $presentedSheet) { sheet in
            if case .weight = sheet, let babyId = selectedBabyId {
                AddWeightEntryView(babyId: babyId)
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder private var mainContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                babyPicker
                dataEntriesList
            }
            .padding()
        }
    }
    
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
            .shadow(radius: 2)
        }
    }
    
    @ViewBuilder private var dataEntriesList: some View {
        ForEach(dataEntries) { entry in
            Button(action: entry.action) {
                HStack(spacing: 16) {
                    Image(systemName: entry.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                    
                    Text(entry.label)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibility(label: Text(entry.label))
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .disabled(selectedBabyId == nil)
        }
    }
    
    // MARK: - Initializer
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
    
    // MARK: - Helper Methods
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

// MARK: - Extensions
extension UserDefaults {
    static let selectedBabyIdKey = "selectedBabyId"
    
    var selectedBabyId: String? {
        get { string(forKey: Self.selectedBabyIdKey) }
        set { setValue(newValue, forKey: Self.selectedBabyIdKey) }
    }
}

#Preview {
    AddDataView(presentingAccount: .constant(false))
        .previewWith(standard: FeedbridgeStandard()) {}
}
