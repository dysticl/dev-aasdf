//
//  ProfileViewModel.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import Combine
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var strengthData: TodayStrengthResponse?
    @Published var intelligenceData: TodayIntelligenceResponse?
    @Published var healthData: TodayHealthResponse?
    @Published var disciplineData: TodayDisciplineResponse?
    @Published var username: String = ""
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var showError = false

    // Image Picker States
    @Published var showImagePicker = false
    @Published var showActionSheet = false
    @Published var inputImage: UIImage?
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary

    // Danger Zone
    @Published var showDeleteConfirmation = false

    private let apiService = APIService.shared

    func loadData() async {
        isLoading = true
        await loadProfile()
        await loadStrength()
        await loadIntelligence()
        await loadHealth()
        await loadDiscipline()
        isLoading = false
    }

    func reloadProfile() async {
        // Pull-to-refresh logic
        await loadProfile()
        await loadStrength()
        await loadIntelligence()
        await loadHealth()
        await loadDiscipline()
    }

    func loadProfile() async {
        do {
            let userProfile = try await apiService.fetchMyProfile()
            self.profile = userProfile
            self.username = userProfile.username
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func loadStrength() async {
        do {
            let data = try await apiService.fetchTodayStrength()
            self.strengthData = data
        } catch {
            print("Failed to load strength data: \(error.localizedDescription)")
            // We don't show an error alert for this, just leave data nil (UI handles it)
        }
    }

    func loadIntelligence() async {
        do {
            let data = try await apiService.fetchTodayIntelligence()
            self.intelligenceData = data
        } catch {
            print("Failed to load intelligence data: \(error.localizedDescription)")
        }
    }

    func loadHealth() async {
        do {
            let data = try await apiService.fetchTodayHealth()
            self.healthData = data
        } catch {
            print("Failed to load health data: \(error.localizedDescription)")
        }
    }

    func loadDiscipline() async {
        do {
            let data = try await apiService.fetchTodayDiscipline()
            self.disciplineData = data
        } catch {
            print("Failed to load discipline data: \(error.localizedDescription)")
        }
    }

    func updateUsername() async {
        guard !username.isEmpty else { return }
        isSaving = true
        do {
            let updatedProfile = try await apiService.updateUsername(username)
            self.profile = updatedProfile
        } catch {
            errorMessage = "Username taken or invalid."
            showError = true
        }
        isSaving = false
    }

    func uploadImage(_ image: UIImage) async {
        isLoading = true
        do {
            try await apiService.uploadProfilePic(image)
            // Refresh profile to get new URL
            // FIX: Add cache buster to ensure immediate update
            let userProfile = try await apiService.fetchMyProfile()
            if let url = userProfile.profilePicUrl {
                let timestamp = Int(Date().timeIntervalSince1970)
                let separator = url.contains("?") ? "&" : "?"
                let newUrl = "\(url)\(separator)t=\(timestamp)"

                // Manually update the profile with the cache-busted URL
                // Since UserProfile is immutable (struct), we create a new one or just rely on the view using the URL
                // But wait, UserProfile is a struct, we can't easily modify one field if it's let.
                // Let's check UserProfile definition. It's likely 'let'.
                // Ideally, the backend would return the new URL, but we just fetch it.
                // We can force the view to reload the image by modifying the URL string locally.

                // Re-construct UserProfile with modified URL for local display
                self.profile = UserProfile(
                    id: userProfile.id,
                    username: userProfile.username,
                    profilePicUrl: newUrl,
                    createdAt: userProfile.createdAt,
                    isActive: userProfile.isActive,
                    walletAddress: userProfile.walletAddress
                )
            } else {
                self.profile = userProfile
            }
        } catch {
            errorMessage = "Failed to upload image."
            showError = true
        }
        isLoading = false
    }

    func deactivateAccount(authViewModel: AuthViewModel) async {
        isLoading = true
        do {
            try await apiService.deactivateAccount()
            authViewModel.logout()
        } catch {
            errorMessage = "Failed to deactivate account."
            showError = true
            isLoading = false
        }
    }

    func shortAddress(_ address: String?) -> String {
        guard let addr = address, addr.count > 10 else { return address ?? "..." }
        return "\(addr.prefix(6))...\(addr.suffix(4))"
    }
}
