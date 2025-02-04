//
//  WeightEntry.swift
//  Feedbridge
//
//  Created by Calvin Xu on 1/30/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import FirebaseFirestore
import Foundation

/// Stores weight measurements (accepts grams, kilograms, or pounds and ounces)
struct WeightEntry: Identifiable, Codable {
    @DocumentID var id: String?

    /// Date and time the weight was measured
    var dateTime: Date

    /// Weight in grams (primary storage)
    var weightInGrams: Double

    var asKilograms: Measurement<UnitMass> {
        Measurement(value: weightInGrams, unit: UnitMass.grams).converted(to: .kilograms)
    }

    var asPounds: Measurement<UnitMass> {
        Measurement(value: weightInGrams, unit: UnitMass.grams).converted(to: .pounds)
    }

    init(grams: Double, dateTime: Date = Date()) {
        self.dateTime = dateTime
        weightInGrams = grams
    }

    init(kilograms: Double, dateTime: Date = Date()) {
        let measurement = Measurement(value: kilograms, unit: UnitMass.kilograms)
        self.dateTime = dateTime
        weightInGrams = measurement.converted(to: .grams).value
    }

    init(pounds: Double, ounces: Double = 0, dateTime: Date = Date()) {
        let totalPounds = pounds + (ounces / 16.0)
        let measurement = Measurement(value: totalPounds, unit: UnitMass.pounds)
        self.dateTime = dateTime
        weightInGrams = measurement.converted(to: .grams).value
    }
}
