//
//  TestModels.swift
//  FeedbridgeTests
//
//  Created by Calvin Xu on 3/9/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation
import Testing

@testable import Feedbridge

struct TestModels {
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
