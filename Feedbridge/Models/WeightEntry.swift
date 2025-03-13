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
@preconcurrency import FirebaseFirestore
import Foundation

/// Stores weight measurements (accepts grams, kilograms, or pounds and ounces)
struct WeightEntry: Identifiable, Codable, Sendable {
    @DocumentID var id: String?

    /// Date and time the weight was measured
    var dateTime: Date

    /// Weight in grams (primary storage)
    var weightInGrams: Int

    var asKilograms: Measurement<UnitMass> {
        Measurement(value: Double(weightInGrams), unit: UnitMass.grams).converted(to: .kilograms)
    }

    var asPounds: Measurement<UnitMass> {
        Measurement(value: Double(weightInGrams), unit: UnitMass.grams).converted(to: .pounds)
    }

    init(grams: Int, dateTime: Date = Date()) {
        self.dateTime = dateTime
        self.weightInGrams = grams
    }

    init(kilograms: Double, dateTime: Date = Date()) {
        let measurement = Measurement(value: kilograms, unit: UnitMass.kilograms)
        self.dateTime = dateTime
        self.weightInGrams = Int(round(measurement.converted(to: .grams).value))
    }

    init(pounds: Int, ounces: Int = 0, dateTime: Date = Date()) {
        let measurement = Measurement(value: Double(pounds) + (Double(ounces) / 16.0), unit: UnitMass.pounds)
        self.dateTime = dateTime
        self.weightInGrams = Int(round(measurement.converted(to: .grams).value))
    }
}
