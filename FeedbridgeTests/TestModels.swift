//
//  TestModels.swift
//  FeedbridgeTests
//
//  Created by Calvin Xu on 3/9/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
// swiftlint:disable type_body_length

import Foundation
import Testing

@testable import Feedbridge

struct TestModels {
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

    // MARK: - DehydrationCheck Tests

    @Test
    func testDehydrationCheckAlert() async throws {
        let noAlertCheck = DehydrationCheck(
            dateTime: .now,
            poorSkinElasticity: false,
            dryMucousMembranes: false
        )
        #expect(!noAlertCheck.dehydrationAlert,
                "No alert should be triggered if both poorSkinElasticity and dryMucousMembranes are false.")

        let alertCheck = DehydrationCheck(
            dateTime: .now,
            poorSkinElasticity: true,
            dryMucousMembranes: false
        )
        #expect(alertCheck.dehydrationAlert,
                "Alert should be triggered if poorSkinElasticity is true.")
    }

    // MARK: - FeedEntry Tests

    @Test
    func testFeedEntryDirectBreastfeeding() async throws {
        let minutes = 20
        let entry = FeedEntry(directBreastfeeding: minutes)

        #expect(entry.feedType == .directBreastfeeding,
                "Feed type should be '.directBreastfeeding' when initialized for breastfeeding.")
        #expect(entry.feedTimeInMinutes == minutes,
                "feedTimeInMinutes should match minutes provided.")
        #expect(entry.milkType == nil,
                "milkType should be nil for directBreastfeeding entries.")
        #expect(entry.feedVolumeInML == nil,
                "feedVolumeInML should be nil for directBreastfeeding entries.")
    }

    @Test
    func testFeedEntryBottleFeeding() async throws {
        let volume = 150
        let entry = FeedEntry(bottle: volume, milkType: .formula)

        #expect(entry.feedType == .bottle,
                "Feed type should be '.bottle' when initialized for bottle feeding.")
        #expect(entry.feedVolumeInML == volume,
                "feedVolumeInML should match volume provided.")
        #expect(entry.milkType == .formula,
                "milkType should be '.formula' when initialized for bottle feeding.")
        #expect(entry.feedTimeInMinutes == nil,
                "feedTimeInMinutes should be nil for bottle feeding entries.")
    }

    // MARK: - StoolEntry Tests

    @Test
    func testStoolEntryMedicalAlert() async throws {
        let entryNormal = StoolEntry(
            dateTime: .now,
            volume: .heavy,
            color: .yellow
        )
        #expect(!entryNormal.medicalAlert,
                "medicalAlert should be false for non-'beige' stool color.")

        let entryAlert = StoolEntry(
            dateTime: .now,
            volume: .medium,
            color: .beige
        )
        #expect(entryAlert.medicalAlert,
                "medicalAlert should be true if the stool color is 'beige'.")
    }

    // MARK: - WeightEntry Tests

    @Test
    func testWeightEntryGrams() async throws {
        let grams = 3200
        let entry = WeightEntry(grams: grams)

        #expect(entry.weightInGrams == grams,
                "weightInGrams should store the exact grams value when initialized with grams.")
        // Check conversions
        let expectedKg = Double(grams) / 1000.0
        #expect(entry.asKilograms.value == expectedKg,
                "asKilograms should match the grams converted to kilograms.")
    }

    @Test
    func testWeightEntryKilograms() async throws {
        let kilograms = 3.2
        let entry = WeightEntry(kilograms: kilograms)

        // 3.2 kg = 3200 grams
        #expect(entry.weightInGrams == 3200,
                "weightInGrams should store correct value when initialized with kilograms.")
        #expect(entry.asKilograms.value == kilograms,
                "asKilograms should reflect the original kg value (approximately).")
    }

    @Test
    func testWeightEntryPoundsOunces() async throws {
        let pounds = 7
        let ounces = 4
        let entry = WeightEntry(pounds: pounds, ounces: ounces)

        // Convert 7 lb 4 oz to grams:
        // 1 lb = 453.59237 g
        // 7 lb = 3175.14659 g
        // 4 oz = 113.39809 g
        // total ~ 3288.54468 g
        // We expect an integer round
        #expect(entry.weightInGrams == 3289,
                "weightInGrams should be approximately 3289 grams for 7 lb 4 oz.")
    }

    // MARK: - WetDiaperEntry Tests

    @Test
    func testWetDiaperEntryDehydrationAlert() async throws {
        let normalWet = WetDiaperEntry(
            dateTime: .now,
            volume: .medium,
            color: .yellow
        )
        #expect(!normalWet.dehydrationAlert,
                "dehydrationAlert should be false for normal color diapers.")

        let pinkWet = WetDiaperEntry(
            dateTime: .now,
            volume: .heavy,
            color: .pink
        )
        #expect(pinkWet.dehydrationAlert,
                "dehydrationAlert should be true for pink diapers.")
    }

    // MARK: - Collection Struct Tests

    @Test
    func testFeedEntriesCollection() async throws {
        var feedEntries = FeedEntries(feedEntries: [])
        #expect(feedEntries.feedEntries.isEmpty,
                "FeedEntries should be empty upon initialization.")

        feedEntries.feedEntries.append(FeedEntry(directBreastfeeding: 10))
        feedEntries.feedEntries.append(FeedEntry(bottle: 60, milkType: .breastmilk))

        #expect(feedEntries.feedEntries.count == 2,
                "FeedEntries collection should contain two items.")
    }

    @Test
    func testWeightEntriesCollection() async throws {
        var weightEntries = WeightEntries(weightEntries: [])
        #expect(weightEntries.weightEntries.isEmpty,
                "WeightEntries should be empty upon initialization.")

        weightEntries.weightEntries.append(WeightEntry(grams: 3000))
        weightEntries.weightEntries.append(WeightEntry(kilograms: 3.5))

        #expect(weightEntries.weightEntries.count == 2,
                "WeightEntries collection should contain two items.")
    }

    @Test
    func testStoolEntriesCollection() async throws {
        var stoolEntries = StoolEntries(stoolEntries: [])
        #expect(stoolEntries.stoolEntries.isEmpty,
                "StoolEntries should be empty upon initialization.")

        stoolEntries.stoolEntries.append(
            StoolEntry(dateTime: .now, volume: .light, color: .yellow)
        )
        stoolEntries.stoolEntries.append(
            StoolEntry(dateTime: .now, volume: .heavy, color: .beige)
        )

        #expect(stoolEntries.stoolEntries.count == 2,
                "StoolEntries collection should contain two items.")
    }

    @Test
    func testWetDiaperEntriesCollection() async throws {
        var wetDiaperEntries = WetDiaperEntries(wetDiaperEntries: [])
        #expect(wetDiaperEntries.wetDiaperEntries.isEmpty,
                "WetDiaperEntries should be empty upon initialization.")

        wetDiaperEntries.wetDiaperEntries.append(
            WetDiaperEntry(dateTime: .now, volume: .medium, color: .yellow)
        )
        wetDiaperEntries.wetDiaperEntries.append(
            WetDiaperEntry(dateTime: .now, volume: .heavy, color: .pink)
        )

        #expect(wetDiaperEntries.wetDiaperEntries.count == 2,
                "WetDiaperEntries collection should contain two items.")
    }

    @Test
    func testDehydrationChecksCollection() async throws {
        var dehydrationChecks = DehydrationChecks(dehydrationChecks: [])
        #expect(dehydrationChecks.dehydrationChecks.isEmpty,
                "DehydrationChecks should be empty upon initialization.")

        dehydrationChecks.dehydrationChecks.append(
            DehydrationCheck(
                dateTime: .now,
                poorSkinElasticity: false,
                dryMucousMembranes: true
            )
        )
        dehydrationChecks.dehydrationChecks.append(
            DehydrationCheck(
                dateTime: .now,
                poorSkinElasticity: true,
                dryMucousMembranes: false
            )
        )

        #expect(dehydrationChecks.dehydrationChecks.count == 2,
                "DehydrationChecks collection should contain two items.")
    }
}
