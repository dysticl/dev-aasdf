//
//  ProfileView.swift
//  dev-aasdf
//
//  Solo Leveling Profile View with Circular XP Ring & Liquid Glass
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @FocusState private var isUsernameFocused: Bool

    // Calculated progress for XP Ring
    var xpProgress: Double {
        guard let profile = viewModel.profile, profile.nextLevelExp > 0 else { return 0.0 }
        return Double(profile.currentExp) / Double(profile.nextLevelExp)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.shadowBackground.ignoresSafeArea()

                if viewModel.isLoading && viewModel.profile == nil {
                    ProgressView()
                        .tint(.white)
                } else {
                    ScrollView {
                        VStack(spacing: DesignSystem.Spacing.xxl) {
                            // Circular XP Header
                            circularHeader

                            // Username Input
                            usernameSection

                            // Hunter Stats
                            statsRow

                            // Info Cards
                            infoCardsSection

                            Spacer(minLength: 40)

                            // Danger Zone
                            dangerZone
                        }
                        .padding(.vertical, 32)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        await viewModel.reloadProfile()
                    }
                }
            }
        }
        .task {
            if viewModel.profile == nil {
                await viewModel.loadData()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .confirmationDialog("Change Profile Picture", isPresented: $viewModel.showActionSheet) {
            Button("Camera") {
                viewModel.sourceType = .camera
                viewModel.showImagePicker = true
            }
            Button("Photo Library") {
                viewModel.sourceType = .photoLibrary
                viewModel.showImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(image: $viewModel.inputImage, sourceType: viewModel.sourceType)
                .ignoresSafeArea()
        }
        .onChange(of: viewModel.inputImage) { _, newImage in
            if let img = newImage {
                Task { await viewModel.uploadImage(img) }
            }
        }
        .alert("Deactivate Account?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Deactivate", role: .destructive) {
                Task { await viewModel.deactivateAccount(authViewModel: authViewModel) }
            }
        } message: {
            Text("This action cannot be undone. You will be logged out immediately.")
        }
    }

    // MARK: - Circular Header

    private var circularHeader: some View {
        VStack(spacing: 20) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 160, height: 160)

                // Progress circle
                Circle()
                    .trim(from: 0, to: xpProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.violetGlow, .violetGlow.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .violetGlow()

                // Content inside circle (Profile Pic or Info)
                Button(action: { viewModel.showActionSheet = true }) {
                    ZStack {
                        if let urlString = viewModel.profile?.profilePicUrl,
                            let url = URL(string: urlString)
                        {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fill)
                                default:
                                    Color.black.opacity(0.5)
                                }
                            }
                        } else {
                            // Default Level display if no image
                            VStack(spacing: 4) {
                                Text("LV.")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.shadowTextSecondary)

                                Text("\(viewModel.profile?.level ?? 1)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.shadowText)
                            }
                        }
                    }
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                }

                // Edit Icon Badge
                Image(systemName: "camera.fill")
                    .font(.caption)
                    .padding(6)
                    .background(Circle().fill(Color.violetGlow))
                    .offset(x: 50, y: 50)
            }

            // XP Text
            Text("\(Int(xpProgress * 100))% to next level")
                .font(.subheadline)
                .foregroundStyle(Color.shadowTextSecondary)
        }
    }

    // MARK: - Username Section

    private var usernameSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("CODENAME")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(SoloColors.textTertiary)
                .tracking(2)

            HStack(spacing: DesignSystem.Spacing.sm) {
                TextField("Username", text: $viewModel.username)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isUsernameFocused)
                    .submitLabel(.done)

                if viewModel.isSaving {
                    ProgressView().tint(.white)
                        .scaleEffect(0.8)
                } else if viewModel.username != viewModel.profile?.username
                    && !viewModel.username.isEmpty
                {
                    Button(action: {
                        isUsernameFocused = false
                        Task { await viewModel.updateUsername() }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SoloColors.successGreen)
                            .font(.title3)
                    }
                }
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ProfileStatCard(
                title: "Intel",
                value: viewModel.intelligenceData?.intelligenceTotalScore.map { String(Int($0)) }
                    ?? "—",
                icon: "brain.head.profile",
                color: SoloColors.electricBlue,
                isLoading: viewModel.intelligenceData == nil && viewModel.isLoading
            )

            ProfileStatCard(
                title: "Strength",
                value: viewModel.strengthData?.strengthTotalScore.map { String(Int($0)) } ?? "—",
                icon: "flame.fill",
                color: SoloColors.dangerRed,
                isLoading: viewModel.strengthData == nil && viewModel.isLoading
            )

            ProfileStatCard(
                title: "Discipline",
                value: viewModel.disciplineData?.disciplineTotalScore.map { String(Int($0)) }
                    ?? "—",
                icon: "target",
                color: SoloColors.hunterPurple,
                isLoading: viewModel.disciplineData == nil && viewModel.isLoading
            )

            ProfileStatCard(
                title: "Health",
                value: viewModel.healthData?.healthTotalScore.map { String(Int($0)) } ?? "—",
                icon: "heart.fill",
                color: SoloColors.successGreen,
                isLoading: viewModel.healthData == nil && viewModel.isLoading
            )
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Info Cards Section

    private var infoCardsSection: some View {
        VStack(spacing: 16) {
            // Member Since Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundStyle(Color.violetGlow)

                    Text("Member Since")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.shadowTextSecondary)
                }

                Text(viewModel.profile?.formattedJoinDate ?? "Loading...")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.shadowText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .shadowLiquidGlass(cornerRadius: 20)

            // Wallet Address Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "wallet.pass")
                        .font(.title2)
                        .foregroundStyle(Color.violetGlow)

                    Text("Wallet Address")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.shadowTextSecondary)
                }

                HStack {
                    Text(viewModel.shortAddress(viewModel.profile?.walletAddress))
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(Color.shadowText)

                    Spacer()

                    Button {
                        if let addr = viewModel.profile?.walletAddress {
                            UIPasteboard.general.string = addr
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.title3)
                            .foregroundStyle(Color.violetGlow)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .shadowLiquidGlass(cornerRadius: 20)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        Button(action: { viewModel.showDeleteConfirmation = true }) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "exclamationmark.triangle")
                Text("Deactivate Account")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(SoloColors.dangerRed.opacity(0.8))
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                Capsule()
                    .stroke(SoloColors.dangerRed.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.bottom, DesignSystem.Spacing.xxl)
    }
}

// MARK: - Helper Components

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isLoading: Bool = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color.opacity(0.8))

            if isLoading {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(0.7)
            } else {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(SoloColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .glassCard(
            cornerRadius: DesignSystem.CornerRadius.small,
            strokeColor: color,
            strokeOpacity: 0.2)
    }
}
