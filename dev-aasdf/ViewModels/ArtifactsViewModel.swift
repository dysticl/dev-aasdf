//
//  ArtifactsViewModel.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 06.12.25.
//

import Combine
import Foundation

@MainActor
class ArtifactsViewModel: ObservableObject {
    @Published var artifacts: [Artifact] = []
    @Published var categories: [ArtifactCategory] = []
    @Published var selectedArtifact: ArtifactDetail?

    // UI State
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    // Filters
    @Published var selectedStatus: String? = nil
    @Published var selectedCategory: String? = nil

    // Creation State
    @Published var createdArtifact: Artifact?

    private let apiService = APIService.shared

    var filteredArtifacts: [Artifact] {
        // Since the backend handles filtering, this local filtering is mostly for immediate UI updates
        // or if we fetch all and filter locally. The backend listArtifacts has filters.
        // We will trust the API response primarily, but can double check.
        return artifacts
    }

    // MARK: - API Calls

    func fetchCategories() async {
        do {
            let categories = try await apiService.getCategories()
            self.categories = categories
        } catch {
            print("Failed to fetch categories: \(error.localizedDescription)")
            // Non-critical, can retry silently or show error if needed
        }
    }

    func fetchArtifacts() async {
        isLoading = true
        do {
            let response = try await apiService.listArtifacts(
                status: selectedStatus,
                category: selectedCategory,
                limit: 50  // Fetch a good amount
            )
            self.artifacts = response.items
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    func createArtifact(
        taskName: String,
        description: String,
        category: String,
        estimatedHours: Double,
        priority: String?,
        deadline: Date?
    ) async -> Bool {
        isLoading = true
        do {
            let response = try await apiService.createArtifact(
                taskName: taskName,
                description: description,
                category: category,
                estimatedHours: estimatedHours,
                priority: priority,
                deadline: deadline
            )

            // Add to list immediately or refresh
            // Since response doesn't contain full artifact detail (backend returns CreateArtifactResponse),
            // we should probably just refresh or manually construct list item.
            // Let's refresh for consistency.
            await fetchArtifacts()
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            return false
        }
    }

    func fetchArtifactDetail(artifactId: String) async {
        isLoading = true
        do {
            let detail = try await apiService.fetchArtifactDetail(artifactId: artifactId)
            self.selectedArtifact = detail
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    func startArtifact(artifactId: String) async {
        isLoading = true
        do {
            _ = try await apiService.startArtifact(artifactId: artifactId)
            // Refresh detail
            await fetchArtifactDetail(artifactId: artifactId)
            // Also refresh list to update status there
            await fetchArtifacts()
        } catch {
            errorMessage = "Failed to start: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }

    func uploadProof(
        artifactId: String,
        files: [(data: Data, mimeType: String, filename: String)],
        actualHours: Double
    ) async -> Bool {
        isLoading = true
        do {
            _ = try await apiService.uploadProof(
                artifactId: artifactId,
                files: files,
                actualHours: actualHours
            )
            await fetchArtifactDetail(artifactId: artifactId)
            await fetchArtifacts()
            return true
        } catch {
            errorMessage = "Upload failed: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }

    func completeArtifact(
        artifactId: String,
        actualHours: Double,
        userNote: String?
    ) async -> CompletionResponse? {
        isLoading = true
        do {
            let response = try await apiService.completeArtifact(
                artifactId: artifactId,
                actualHours: actualHours,
                userNote: userNote
            )
            await fetchArtifactDetail(artifactId: artifactId)
            await fetchArtifacts()
            return response
        } catch {
            errorMessage = "Completion failed: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return nil
        }
    }

    func cancelArtifact(artifactId: String) async {
        isLoading = true
        do {
            _ = try await apiService.cancelArtifact(artifactId: artifactId)
            await fetchArtifacts()
            // If we are in detail view, we should probably pop back, but for now just refresh detail
            if selectedArtifact?.artifactId == artifactId {
                await fetchArtifactDetail(artifactId: artifactId)
            }
        } catch {
            errorMessage = "Cancel failed: \(error.localizedDescription)"
            showError = true
        }
        isLoading = false
    }

    // MARK: - Helpers

    func getCategoryIcon(for categoryName: String) -> String {
        return categories.first(where: { $0.name == categoryName })?.iconUrl ?? "📋"
    }
}
