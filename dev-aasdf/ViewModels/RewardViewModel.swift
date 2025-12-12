//
//  RewardViewModel.swift
//  dev-aasdf
//
//  Adaptive Reward System ViewModel
//  Manages wish pool, claims, and reward engine state
//

import Combine
import SwiftUI

@MainActor
class RewardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var wishes: [WishResponse] = []
    @Published var userProfile: RewardUserProfileResponse?
    @Published var engineHealth: RewardEngineHealthResponse?

    @Published var isLoading = false
    @Published var isClaimingWish = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var successMessage: String?
    @Published var showSuccess = false

    // Claim flow state
    @Published var selectedWish: WishResponse?
    @Published var showClaimSheet = false
    @Published var lastClaimResponse: RewardClaimResponse?

    private let apiService = APIService.shared

    // MARK: - Computed Properties

    var availableWishes: [WishResponse] {
        wishes.filter { $0.status == .AVAILABLE && $0.isActive }
    }

    var cooldownWishes: [WishResponse] {
        wishes.filter { $0.status == .COOLDOWN && $0.isActive }
    }

    var lockedWishes: [WishResponse] {
        wishes.filter { $0.status == .LOCKED && $0.isActive }
    }

    var claimableWishes: [WishResponse] {
        guard let profile = userProfile else { return [] }
        return availableWishes.filter { $0.isClaimable(userXp: profile.progression.xpCurrent) }
    }

    var totalWishCount: Int {
        wishes.filter { $0.isActive }.count
    }

    var currentXp: Int {
        userProfile?.progression.xpCurrent ?? 0
    }

    var currentLevel: Int {
        userProfile?.progression.level ?? 1
    }

    var xpToNextLevel: Int {
        userProfile?.progression.xpToNextLevel ?? 100
    }

    var xpProgressRatio: Double {
        userProfile?.progression.xpProgressRatio ?? 0
    }

    var motivationPhase: Int {
        userProfile?.motivation.motivationPhase ?? 7
    }

    var phaseDescription: String {
        userProfile?.motivation.phaseDescription ?? "Neutral"
    }

    var circuitBreakerActive: Bool {
        userProfile?.motivation.circuitBreakerActive ?? false
    }

    var isEngineHealthy: Bool {
        engineHealth?.isHealthy ?? false
    }

    // MARK: - Data Loading

    func loadAllData() async {
        isLoading = true
        errorMessage = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadWishes() }
            group.addTask { await self.loadUserProfile() }
            group.addTask { await self.loadEngineHealth() }
        }

        isLoading = false
    }

    func loadWishes() async {
        do {
            let response = try await apiService.fetchWishes()
            self.wishes = response.wishes
        } catch {
            print("Failed to load wishes: \(error)")
            // Don't show error for wishes, might just be empty
        }
    }

    func loadUserProfile() async {
        do {
            // First get user ID from stored data or auth
            guard let userId = getCurrentUserId() else {
                print("No user ID available for reward profile")
                return
            }
            let profile = try await apiService.fetchRewardUserProfile(userId: userId)
            self.userProfile = profile
        } catch {
            print("Failed to load reward user profile: \(error)")
            // Non-critical, don't block UI
        }
    }

    func loadEngineHealth() async {
        do {
            let health = try await apiService.fetchRewardEngineHealth()
            self.engineHealth = health
        } catch {
            print("Failed to check reward engine health: \(error)")
        }
    }

    func refresh() async {
        await loadAllData()
    }

    // MARK: - Wish Actions

    func selectWishForClaim(_ wish: WishResponse) {
        guard wish.status == .AVAILABLE else {
            showErrorMessage("This wish is not available for claiming.")
            return
        }

        guard let cost = wish.currentXpCost, currentXp >= cost else {
            showErrorMessage("Not enough XP to claim this wish.")
            return
        }

        if circuitBreakerActive {
            showErrorMessage("Circuit breaker is active. High-dopamine rewards are temporarily locked.")
            return
        }

        selectedWish = wish
        showClaimSheet = true
    }

    func claimWish(satisfactionScore: Double) async {
        guard let wish = selectedWish else { return }
        guard let userId = getCurrentUserId() else {
            showErrorMessage("User not authenticated.")
            return
        }

        isClaimingWish = true
        errorMessage = nil

        do {
            // Use the full reward engine claim endpoint
            let response = try await apiService.claimRewardEngine(
                wishId: wish.wishId,
                userId: userId,
                satisfactionScore: satisfactionScore
            )

            lastClaimResponse = response
            showClaimSheet = false
            selectedWish = nil

            // Show success message
            showSuccessMessage("Claimed \(response.wishTitle)! XP: \(response.xpBefore) → \(response.xpAfter)")

            // Refresh data to update UI
            await loadAllData()

        } catch {
            showErrorMessage("Failed to claim reward: \(error.localizedDescription)")
        }

        isClaimingWish = false
    }

    func cancelClaim() {
        showClaimSheet = false
        selectedWish = nil
    }

    // MARK: - Create Wish

    func createWish(
        title: String,
        description: String? = nil,
        dopaminePotential: Int = 50,
        rarity: WishRarity = .COMMON,
        volatilityRisk: VolatilityRisk = .LOW,
        cooldownHours: Int = 24,
        longtermImpact: Int = 50
    ) async {
        let request = WishCreateRequest(
            title: title,
            description: description,
            baseDopaminePotential: dopaminePotential,
            rarity: rarity,
            volatilityRisk: volatilityRisk,
            cooldownHours: cooldownHours,
            longtermImpact: longtermImpact
        )

        do {
            let newWish = try await apiService.createWish(request)
            wishes.append(newWish)
            showSuccessMessage("Created new wish: \(newWish.title)")
        } catch {
            showErrorMessage("Failed to create wish: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete Wish

    func deleteWish(_ wish: WishResponse) async {
        do {
            _ = try await apiService.deleteWish(wishId: wish.wishId)
            wishes.removeAll { $0.wishId == wish.wishId }
            showSuccessMessage("Deleted wish: \(wish.title)")
        } catch {
            showErrorMessage("Failed to delete wish: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func getCurrentUserId() -> String? {
        // Try multiple possible keys for user ID
        return UserDefaults.standard.string(forKey: "user_id")
            ?? UserDefaults.standard.string(forKey: "userId")
            ?? UserDefaults.standard.string(forKey: "current_user_id")
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true

        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showError = false
        }
    }

    private func showSuccessMessage(_ message: String) {
        successMessage = message
        showSuccess = true

        // Auto-dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showSuccess = false
        }
    }
}

// MARK: - Preview Helper

extension RewardViewModel {
    static var preview: RewardViewModel {
        let vm = RewardViewModel()

        // Mock wishes
        vm.wishes = [
            WishResponse(
                wishId: "wish-1",
                userId: "user-1",
                title: "1h Anime Marathon",
                description: "Watch Solo Leveling episodes",
                baseDopaminePotential: 75,
                rarity: .RARE,
                volatilityRisk: .MEDIUM,
                cooldownHours: 24,
                longtermImpact: 30,
                history: WishHistory(timesUsed: 5, avgSatisfaction: 8.5),
                lastUsed: nil,
                currentXpCost: 350,
                isActive: true,
                status: .AVAILABLE,
                createdAt: nil,
                updatedAt: nil,
                desensAlert: false,
                cooldownRemainingHours: nil
            ),
            WishResponse(
                wishId: "wish-2",
                userId: "user-1",
                title: "Gaming Session",
                description: "1 hour of gaming",
                baseDopaminePotential: 80,
                rarity: .COMMON,
                volatilityRisk: .HIGH,
                cooldownHours: 48,
                longtermImpact: 20,
                history: WishHistory(timesUsed: 12, avgSatisfaction: 7.2, desensTrend: 0.65),
                lastUsed: "2025-12-10T18:00:00Z",
                currentXpCost: 500,
                isActive: true,
                status: .COOLDOWN,
                createdAt: nil,
                updatedAt: nil,
                desensAlert: false,
                cooldownRemainingHours: 18
            ),
            WishResponse(
                wishId: "wish-3",
                userId: "user-1",
                title: "Special Treat",
                description: "Buy yourself something nice",
                baseDopaminePotential: 90,
                rarity: .LEGENDARY,
                volatilityRisk: .LOW,
                cooldownHours: 168,
                longtermImpact: 60,
                history: WishHistory(timesUsed: 1),
                lastUsed: nil,
                currentXpCost: 1000,
                isActive: true,
                status: .AVAILABLE,
                createdAt: nil,
                updatedAt: nil,
                desensAlert: false,
                cooldownRemainingHours: nil
            )
        ]

        // Mock user profile
        vm.userProfile = RewardUserProfileResponse(
            userId: "user-1",
            username: "@ShadowMonarch",
            profilePicUrl: nil,
            motivation: RewardMotivationState(
                dopamineSensitivity: 0.65,
                motivationPhase: 5,
                haHistoryAdjustment: 55.0,
                toleranceRisk: 0.3,
                highDpClaims24h: 1,
                circuitBreakerActive: false,
                circuitBreakerUntil: nil
            ),
            receptor: RewardReceptorContext(
                cleanDaysLast30: 22,
                dirtyDaysLast30: 3,
                netCleanScore: 16.0,
                dopamineBaseline: 0.55,
                lastRelapseDate: nil,
                previousStreakBeforeRelapse: nil,
                daysSinceRelapse: nil
            ),
            progression: RewardProgressState(
                level: 42,
                xpCurrent: 750,
                xpToNextLevel: 1000,
                currentStreak: 12,
                longestStreak: 45,
                totalTasksCompleted: 156,
                totalTasksFailed: 8,
                lastLevelUp: nil
            )
        )

        vm.engineHealth = RewardEngineHealthResponse(
            status: "healthy",
            services: nil,
            message: "Reward Engine is operational"
        )

        return vm
    }
}
