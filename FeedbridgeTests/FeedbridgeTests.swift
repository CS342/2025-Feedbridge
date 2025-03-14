//
// This source file is part of the Feedbridge based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import Feedbridge

import Foundation
import Testing

@MainActor
struct FeedbridgeTests {
    // MARK: - Baby Tests

    @Test
    func testBabyInitialization() async throws {
        let name = "Baby John"
        let dateOfBirth = Date(timeIntervalSince1970: 1_600_000_000) // Some fixed date
        let baby = Baby(name: name, dateOfBirth: dateOfBirth)

        #expect(baby.name == name, "Baby name should match the assigned value.")
        #expect(baby.dateOfBirth == dateOfBirth, "Date of birth should match the assigned value.")
        #expect(baby.feedEntries.feedEntries.isEmpty, "feedEntries should be empty by default.")
        #expect(baby.weightEntries.weightEntries.isEmpty, "weightEntries should be empty by default.")
        #expect(baby.stoolEntries.stoolEntries.isEmpty, "stoolEntries should be empty by default.")
        #expect(baby.wetDiaperEntries.wetDiaperEntries.isEmpty, "wetDiaperEntries should be empty by default.")
        #expect(baby.dehydrationChecks.dehydrationChecks.isEmpty, "dehydrationChecks should be empty by default.")
    }

    @Test
    func testBabyEqualityWithIDs() async throws {
        // Both babies have the same id.
        var babyA = Baby(name: "Baby A", dateOfBirth: .now)
        var babyB = Baby(name: "Baby B", dateOfBirth: .now)
        babyA.id = "same-id"
        babyB.id = "same-id"

        #expect(babyA == babyB, "Babies should be equal when their IDs match.")

        // Different IDs
        babyB.id = "different-id"

        #expect(babyA != babyB, "Babies should not be equal when their IDs differ.")
    }

    @Test
    func testBabyEqualityWithoutIDs() async throws {
        // Babies have no IDs but the same name + DOB
        let dateOfBirth = Date()
        let babyA = Baby(name: "Baby A", dateOfBirth: dateOfBirth)
        let babyB = Baby(name: "Baby A", dateOfBirth: dateOfBirth)

        #expect(babyA == babyB, "Babies should be equal when both ID are nil but name and dateOfBirth match.")

        // Different name
        let babyC = Baby(name: "Baby C", dateOfBirth: dateOfBirth)
        #expect(babyA != babyC, "Babies should not be equal when name differs and no IDs are set.")
    }

    @Test
    func testBabyAgeInMonths() async throws {
        // Assuming "dateOfBirth" is 3 months ago from "now" in a simplified scenario
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        let baby = Baby(name: "Baby Age Test", dateOfBirth: threeMonthsAgo)

        #expect(baby.ageInMonths == 3, "Baby ageInMonths should be 3 (approximately).")
    }

    @Test
    func testBabyCurrentWeight() async throws {
        let baby = Baby(name: "WeightTest", dateOfBirth: .now)
        #expect(baby.currentWeight == nil, "currentWeight should be nil when no entries exist.")

        var weightEntries = WeightEntries(weightEntries: [])
        weightEntries.weightEntries.append(WeightEntry(
            grams: 3000,
            dateTime: Date(timeIntervalSinceNow: -3600)
        ))
        weightEntries.weightEntries.append(WeightEntry(
            grams: 3500,
            dateTime: Date(timeIntervalSinceNow: -1800)
        ))
        weightEntries.weightEntries.append(WeightEntry(
            grams: 3600,
            dateTime: Date(timeIntervalSinceNow: -60)
        ))

        var modifiableBaby = baby
        modifiableBaby.weightEntries = weightEntries

        #expect(modifiableBaby.currentWeight?.weightInGrams == 3600,
                "Most recent weight entry should be 3600 grams.")
    }

    @Test
    func testBabyLatestDehydrationCheck() async throws {
        let baby = Baby(name: "DehydrationTest", dateOfBirth: .now)
        #expect(baby.latestDehydrationCheck == nil, "Should be nil when no dehydration checks exist.")

        var dehydrationChecks = DehydrationChecks(dehydrationChecks: [])
        let oldCheck = DehydrationCheck(
            dateTime: Date(timeIntervalSinceNow: -3600),
            poorSkinElasticity: false,
            dryMucousMembranes: false
        )
        let recentCheck = DehydrationCheck(
            dateTime: Date(timeIntervalSinceNow: -300),
            poorSkinElasticity: true,
            dryMucousMembranes: true
        )

        dehydrationChecks.dehydrationChecks.append(oldCheck)
        dehydrationChecks.dehydrationChecks.append(recentCheck)

        var modifiableBaby = baby
        modifiableBaby.dehydrationChecks = dehydrationChecks

        #expect(modifiableBaby.latestDehydrationCheck?.dateTime == recentCheck.dateTime,
                "Latest check should be the one with the greatest dateTime.")
    }

    @Test
    func testBabyHasActiveAlerts() async throws {
        // Baby with no alerts
        let babyNoAlerts = Baby(name: "NoAlerts", dateOfBirth: .now)
        #expect(!babyNoAlerts.hasActiveAlerts, "Should have no active alerts initially.")

        // Baby with an active dehydration check
        var babyDehydrationAlert = babyNoAlerts
        let dehydratedCheck = DehydrationCheck(
            dateTime: .now,
            poorSkinElasticity: true,
            dryMucousMembranes: false
        )
        babyDehydrationAlert.dehydrationChecks = DehydrationChecks(dehydrationChecks: [dehydratedCheck])
        #expect(babyDehydrationAlert.hasActiveAlerts, "Should have an active alert from dehydration check.")

        // Baby with an active wet diaper alert
        var babyWetDiaperAlert = babyNoAlerts
        let wetDiaperAlert = WetDiaperEntry(
            dateTime: .now,
            volume: .heavy,
            color: .redTinged
        )
        babyWetDiaperAlert.wetDiaperEntries = WetDiaperEntries(wetDiaperEntries: [wetDiaperAlert])
        #expect(babyWetDiaperAlert.hasActiveAlerts, "Should have an active alert from wet diaper entry.")

        // Baby with an active stool alert
        var babyStoolAlert = babyNoAlerts
        let stoolAlert = StoolEntry(
            dateTime: .now,
            volume: .heavy,
            color: .beige
        )
        babyStoolAlert.stoolEntries = StoolEntries(stoolEntries: [stoolAlert])
        #expect(babyStoolAlert.hasActiveAlerts, "Should have an active alert from stool entry.")
    }
}
