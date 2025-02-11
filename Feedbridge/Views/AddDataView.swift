//
//  AddDataView.swift
//  Feedbridge
//
//  Created by Shamit Surana on 2/8/25.
//

import Foundation
import SpeziAccount
import SwiftUI

struct AddDataAView: View {
    // MARK: - Properties
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

    private let dataEntries: [DataEntry] = [
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
            action: { /* logic to handle weight entry */ }
        )
    ]

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
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
                    }
                }
                .padding()
            }
            .navigationTitle("Add Data")
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
    }

    // MARK: - Initializer
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}

// MARK: - Supporting Types
extension AddDataAView {
    struct DataEntry: Identifiable {
        let id = UUID()
        let label: String
        let imageName: String
        let action: () -> Void
    }
}

#if DEBUG
#Preview {
    AddDataAView(presentingAccount: .constant(false))
}
#endif
