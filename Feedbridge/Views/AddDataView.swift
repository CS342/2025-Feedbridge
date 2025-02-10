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
            image: Image("flame.fill", label: Text("Feed")),
            action: { /* logic to handle feed entry */ }
        ),
        DataEntry(
            label: "Wet Diaper Entry",
            image: Image("drop.fill", label: Text("Wet diaper")),
            action: { /* logic to handle wet diaper entry */ }
        ),
        DataEntry(
            label: "Stool Entry",
            image: Image("plus.circle.fill", label: Text("Stool Entry")),
            action: { /* logic to handle stool entry */ }
        ),
        DataEntry(
            label: "Dehydration Check",
            image: Image("exclamationmark.triangle.fill", label: Text("Dehydration Check")),
            action: { /* logic to handle dehydration check */ }
        ),
        DataEntry(
            label: "Weight Entry",
            image: Image("scalemass.fill", label: Text("Weight Entry")),
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
                                entry.image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                
                                Text(entry.label)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
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
        let image: Image
        let action: () -> Void
    }
}

#if DEBUG
#Preview {
    AddDataAView(presentingAccount: .constant(false))
}
#endif
 
