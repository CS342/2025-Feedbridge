//
//  DashboardViewModel.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import SwiftUI
import SpeziAccount
// swiftlint:disable closure_body_length
// swiftlint:disable type_body_length
@MainActor
class DashboardViewModel: ObservableObject {
    @Environment(FeedbridgeStandard.self) private var standard

    @Published var babies: [Baby] = []
    @Published var selectedBabyId: String?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var baby: Baby?


//    private let standard: FeedbridgeStandard

    init(standard: FeedbridgeStandard) {
        self.standard = standard
    }

    func loadBabies() async {
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

    func loadBaby() async {
        guard let babyId = selectedBabyId else {
            baby = nil
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            baby = try await standard.getBaby(id: babyId)
        } catch {
            errorMessage = "Failed to load baby: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
