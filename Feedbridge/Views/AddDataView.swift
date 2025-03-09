////
////  AddDataView.swift
////  Feedbridge
////
////  Created by Shamit Surana on 2/8/25.
////
//// SPDX-FileCopyrightText: 2025 Stanford University
////
//// SPDX-License-Identifier: MIT
////
//
//import Foundation
//import SpeziAccount
//import SwiftUI
//
//struct AddDataView: View {
//    // MARK: - Type Definitions
//
//    private enum DataEntrySheet: Identifiable {
//        case weight
//        case dehydration
//        case feed
//        case wetDiaper
//        case stool
//
//        var id: Int {
//            switch self {
//            case .weight: return 1
//            case .dehydration: return 2
//            case .feed: return 3
//            case .wetDiaper: return 4
//            case .stool: return 5
//            }
//        }
//    }
//
//    struct DataEntry: Identifiable {
//        let id = UUID()
//        let label: String
//        let imageName: String
//        let action: () -> Void
//    }
//
//    // MARK: - Properties
//
//    @Environment(Account.self) private var account: Account?
//    @Environment(FeedbridgeStandard.self) private var standard
//    @Binding var presentingAccount: Bool
//
//    @State private var babies: [Baby] = []
//    @State private var selectedBabyId: String?
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//    @State private var presentedSheet: DataEntrySheet?
//
//    private var dataEntries: [DataEntry] {
//        [
//            DataEntry(
//                label: "Feed Entry",
//                imageName: "flame.fill",
//                action: { presentedSheet = .feed }
//            ),
//            DataEntry(
//                label: "Wet Diaper Entry",
//                imageName: "drop.fill",
//                action: { presentedSheet = .wetDiaper }
//            ),
//            DataEntry(
//                label: "Stool Entry",
//                imageName: "plus.circle.fill",
//                action: { presentedSheet = .stool }
//            ),
//            DataEntry(
//                label: "Dehydration Check",
//                imageName: "exclamationmark.triangle.fill",
//                action: { presentedSheet = .dehydration }
//            ),
//            DataEntry(
//                label: "Weight Entry",
//                imageName: "scalemass.fill",
//                action: { presentedSheet = .weight }
//            )
//        ]
//    }
//
//    // MARK: - View Body
//
//    var body: some View {
//        NavigationStack {
//            Group {
//                if isLoading {
//                    ProgressView()
//                } else if let error = errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                } else {
//                    mainContent
//                }
//            }
//            .navigationTitle("Add Data")
//            .toolbar {
//                if account != nil {
//                    AccountButton(isPresented: $presentingAccount)
//                }
//            }
//            .task {
//                await loadBabies()
//            }
//        }
//        .sheet(item: $presentedSheet) { sheet in
//            if let babyId = selectedBabyId {
//                switch sheet {
//                case .weight:
//                    AddWeightEntryView(babyId: babyId)
//                case .dehydration:
//                    AddDehydrationCheckView(babyId: babyId)
//                case .feed:
//                    AddFeedEntryView(babyId: babyId)
//                case .wetDiaper:
//                    AddWetDiaperEntryView(babyId: babyId)
//                case .stool:
//                    AddStoolEntryView(babyId: babyId)
//                }
//            }
//        }
//    }
//
//    // MARK: - View Components
//
//    @ViewBuilder private var mainContent: some View {
//        ScrollView {
//            VStack(spacing: 16) {
//                babyPicker
//                dataEntriesList
//            }
//            .padding()
//        }
//    }
//
//    @ViewBuilder private var dataEntriesList: some View {
//        ForEach(dataEntries) { entry in
//            Button(action: entry.action) {
//                HStack(spacing: 16) {
//                    Image(systemName: entry.imageName)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 24, height: 24)
//                        .foregroundColor(.white)
//
//                    Text(entry.label)
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                .accessibility(label: Text(entry.label))
//                .padding()
//                .background(Color.blue)
//                .cornerRadius(8)
//            }
//            .disabled(selectedBabyId == nil)
//        }
//    }
//
//    // MARK: - Initializer
//
//    init(presentingAccount: Binding<Bool>) {
//        _presentingAccount = presentingAccount
//    }
//
//    
//}
//
//
//
//#Preview {
//    AddDataView(presentingAccount: .constant(false))
//        .previewWith(standard: FeedbridgeStandard()) {}
//}
