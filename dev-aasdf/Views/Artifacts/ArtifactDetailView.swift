//
//  ArtifactDetailView.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 06.12.25.
//

import SwiftUI

struct ArtifactDetailView: View {
    let artifactId: String
    @ObservedObject var viewModel: ArtifactsViewModel
    @Environment(\.dismiss) var dismiss

    // Sheets
    @State private var showUploadSheet = false
    @State private var showCompletionView = false
    @State private var completionResponse: CompletionResponse?
    @State private var selectedProof: Proof?
    @State private var showProofViewer = false

    var detail: ArtifactDetail? {
        viewModel.selectedArtifact
    }

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            // Ambient Glow (Top Right)
            Circle()
                .fill(Color.blue.opacity(0.1))
                .blur(radius: 120)
                .offset(x: 100, y: -200)

            if viewModel.isLoading && detail == nil {
                ProgressView()
                    .tint(.white)
            } else if let artifact = detail {
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Header
                        VStack(spacing: 8) {
                            Text(artifact.taskName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 12) {
                                StatusBadge(status: artifact.status)
                                CategoryBadge(category: artifact.category)
                            }
                        }
                        .padding(.top, 20)

                        // MARK: - AI Estimate Card
                        if let estimate = artifact.aiEstimate {
                            ArtifactGlassContainer {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(.yellow)
                                        Text("AI Estimate")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.yellow)
                                        Spacer()
                                        Text("\(estimate.estimatedXp) XP")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }

                                    Divider().background(Color.white.opacity(0.2))

                                    // Life Dimensions
                                    VStack(spacing: 12) {
                                        DimensionRow(
                                            title: "Discipline",
                                            value: estimate.lifeDimensions.discipline)
                                        DimensionRow(
                                            title: "Intelligence",
                                            value: estimate.lifeDimensions.intelligence)
                                        DimensionRow(
                                            title: "Strength",
                                            value: estimate.lifeDimensions.strength)
                                        DimensionRow(
                                            title: "Health", value: estimate.lifeDimensions.health)
                                    }

                                    // Reasoning
                                    Text(estimate.reasoning)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                }
                                .padding()
                            }
                        }

                        // MARK: - Description
                        if let desc = artifact.description, !desc.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Description")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text(desc)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        }

                        // MARK: - Proofs (if completed or awaiting)
                        if !artifact.proofs.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Proofs")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                VStack(spacing: 8) {
                                    ForEach(artifact.proofs) { proof in
                                        Button {
                                            self.selectedProof = proof
                                            self.showProofViewer = true
                                        } label: {
                                            HStack {
                                                Image(systemName: iconName(for: proof.mimeType))
                                                    .foregroundColor(.blue)
                                                Text(proof.filename ?? "Proof File")
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.white.opacity(0.4))
                                            }
                                            .padding()
                                            .background(Material.ultraThinMaterial)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 40)
                    }
                }

                // MARK: - Action Button
                VStack {
                    Spacer()
                    ActionButton(status: artifact.status) {
                        handleAction(for: artifact)
                    }
                    .padding()
                    .padding(.bottom, 20)
                }
            } else {
                Text("Artifact not found")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            Task { await viewModel.fetchArtifactDetail(artifactId: artifactId) }
        }
        .sheet(isPresented: $showUploadSheet) {
            UploadProofView(artifactId: artifactId, viewModel: viewModel) { response in
                // On success, show completion view
                self.completionResponse = response
                self.showCompletionView = true
                Task { await viewModel.fetchArtifactDetail(artifactId: artifactId) }
            }
        }
        .fullScreenCover(item: $completionResponse) { response in
            ArtifactCompletionView(response: response)
        }
        .sheet(isPresented: $showProofViewer) {
            if let proof = selectedProof, let url = URL(string: proof.downloadUrl) {
                ProofPreview(url: url, mimeType: proof.mimeType, title: proof.filename ?? "Proof")
                    .ignoresSafeArea()
            } else {
                Text("Unable to load proof")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if detail?.status != "completed" && detail?.status != "cancelled" {
                    Menu {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.cancelArtifact(artifactId: artifactId)
                                dismiss()
                            }
                        } label: {
                            Label("Cancel Artifact", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    // MARK: - Logic

    func handleAction(for artifact: ArtifactDetail) {
        switch artifact.status {
        case "pending":
            Task { await viewModel.startArtifact(artifactId: artifactId) }
        case "in_progress":
            showUploadSheet = true
        case "awaiting_proof":
            // Usually handled by uploading proof which auto-completes in our simplified flow,
            // but if user backed out, they might need to "Complete".
            // Since our UploadProofView handles completion, we can re-open it or show just complete.
            // For simplicity, reopen upload sheet as it has the logic.
            // OR strictly speaking we should just have a "Complete" button if proofs are there.
            // Let's assume re-opening upload logic allows finishing.
            showUploadSheet = true
        default:
            break
        }
    }

    func iconName(for mime: String) -> String {
        if mime.starts(with: "image/") { return "photo" }
        if mime == "application/pdf" { return "doc.richtext" }
        if mime.starts(with: "video/") { return "video" }
        if mime.starts(with: "audio/") { return "waveform" }
        return "doc.text"
    }
}

// MARK: - Helper Views

struct ArtifactGlassContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(Material.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal)
    }
}

struct DimensionRow: View {
    let title: String
    let value: Double

    var body: some View {
        if value > 0 {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("+\(Int(value))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                // Simple bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.gray.opacity(0.2))
                        Capsule().fill(Color.green).frame(
                            width: geo.size.width * CGFloat(min(value / 10.0, 1.0)))
                    }
                }
                .frame(width: 60, height: 6)
            }
        } else {
            EmptyView()
        }
    }
}

struct StatusBadge: View {
    let status: String

    var color: Color {
        switch status {
        case "pending": return .gray
        case "in_progress": return .blue
        case "awaiting_proof": return .orange
        case "completed": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }

    var body: some View {
        Text(status.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
    }
}

struct CategoryBadge: View {
    let category: String

    var body: some View {
        Text(category)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}

struct ActionButton: View {
    let status: String
    let action: () -> Void

    var body: some View {
        if status == "completed" || status == "cancelled" {
            EmptyView()
        } else {
            Button(action: action) {
                HStack {
                    Text(buttonTitle)
                        .fontWeight(.bold)
                    Image(systemName: buttonIcon)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonColor)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: buttonColor.opacity(0.5), radius: 10, x: 0, y: 5)
            }
        }
    }

    var buttonTitle: String {
        switch status {
        case "pending": return "Start Mission"
        case "in_progress": return "Complete Mission"
        case "awaiting_proof": return "Finalize"
        default: return ""
        }
    }

    var buttonIcon: String {
        switch status {
        case "pending": return "play.fill"
        case "in_progress": return "checkmark.seal.fill"
        default: return "arrow.right"
        }
    }

    var buttonColor: Color {
        switch status {
        case "pending": return .blue
        case "in_progress": return .green
        case "awaiting_proof": return .orange
        default: return .gray
        }
    }
}

// Extension to make CompletionResponse identifiable for FullScreenCover
extension CompletionResponse: Identifiable {
    public var id: String { artifactId }
}

import QuickLook
import SafariServices

struct ProofPreview: View {
    let url: URL
    let mimeType: String
    let title: String

    var body: some View {
        Group {
            if supportsQuickLook(mimeType: mimeType) {
                QLPreviewControllerRepresentable(url: url, title: title)
            } else {
                SafariView(url: url)
            }
        }
    }

    private func supportsQuickLook(mimeType: String) -> Bool {
        // Common types supported by QL
        return mimeType.starts(with: "image/") ||
               mimeType == "application/pdf" ||
               mimeType.starts(with: "video/") ||
               mimeType.starts(with: "audio/")
    }
}

struct QLPreviewControllerRepresentable: UIViewControllerRepresentable {
    let url: URL
    let title: String

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url, title: title)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        let title: String

        init(url: URL, title: String) {
            self.url = url
            self.title = title
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return url as QLPreviewItem
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
