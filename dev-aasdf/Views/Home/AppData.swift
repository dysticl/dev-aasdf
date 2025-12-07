//
//  AppData.swift
//  Shared observable data model
//

import SwiftUI

@Observable
class AppData {
    var level: Int = 42
    var xpProgress: Double = 0.65
    var streakDays: Int = 12
    var streakProgress: Double = 0.48
    var memberSince: String = "January 2024"
    var walletAddress: String = "0x7f2c...a8e9"
    
    // Daily quote
    var dailyQuote: String = "I alone level up."
}
