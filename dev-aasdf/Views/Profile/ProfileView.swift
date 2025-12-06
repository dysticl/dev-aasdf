//
//  ProfileView.swift
//  dev-aasdf
//
//  Solo Leveling Profile View with Liquid Glass design
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @FocusState private var isUsernameFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // Background with Ambient Glows
                AmbientGlowBackground(
                    primaryColor: SoloColors.hunterPurple,
                    secondaryColor: SoloColors.electricBlue,
                    tertiaryColor: SoloColors.xpGold
                )

                if viewModel.isLoading && viewModel.profile == nil {
                    ProgressView()
                        .tint(.white)
                } else {
                    ScrollView {
                        VStack(spacing: DesignSystem.Spacing.xxl) {
                            profileHeader
                            statsRow
                            infoSection

                            Spacer(minLength: 40)

                            dangerZone
                        }
                        .padding(.bottom, 140)  // Space for tab bar
                    }
                    .refreshable {
                        await viewModel.reloadProfile()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
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

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Profile Picture with Gradient Border
            ZStack {
                // Animated gradient border
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                SoloColors.electricBlue,
                                SoloColors.hunterPurple,
                                SoloColors.xpGold,
                                SoloColors.electricBlue,
                            ],
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 130, height: 130)
                    .shadow(color: SoloColors.electricBlue.opacity(0.4), radius: 15)

                if let urlString = viewModel.profile?.profilePicUrl,
                    let url = URL(string: urlString)
                {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().tint(.white)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: "person.fill")
                                .resizable()
                                .foregroundColor(SoloColors.textTertiary)
                                .padding(30)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .id(urlString)
                } else {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .foregroundColor(SoloColors.textTertiary)
                                .padding(30)
                        )
                }

                // Camera Button
                Button(action: { viewModel.showActionSheet = true }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 5)

                        Image(systemName: "camera.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
                .offset(x: 45, y: 45)
            }
            .padding(.top, DesignSystem.Spacing.xl)

            // Username / Codename
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
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ProfileStatCard(
                title: "Intel",
                value: viewModel.intelligenceData.map {
                    if let score = $0.intelligenceTotalScore {
                        return String(Int(score))
                    } else {
                        return "—"
                    }
                } ?? "—",
                icon: "brain.head.profile",
                color: SoloColors.electricBlue,
                isLoading: viewModel.intelligenceData == nil && viewModel.isLoading
            )

            ProfileStatCard(
                title: "Strength",
                value: viewModel.strengthData.map {
                    String(Int($0.strengthTotalScore))
                } ?? "—",
                icon: "flame.fill",
                color: SoloColors.dangerRed,
                isLoading: viewModel.strengthData == nil && viewModel.isLoading
            )

            ProfileStatCard(
                title: "Discipline",
                value: viewModel.disciplineData.map {
                    if let score = $0.disciplineTotalScore {
                        return String(Int(score))
                    } else {
                        return "—"
                    }
                } ?? "—",
                icon: "target",
                color: SoloColors.hunterPurple,
                isLoading: viewModel.disciplineData == nil && viewModel.isLoading
            )

            ProfileStatCard(
                title: "Health",
                value: viewModel.healthData.map {
                    if let score = $0.healthTotalScore {
                        return String(Int(score))
                    } else {
                        return "—"
                    }
                } ?? "—",
                icon: "heart.fill",
                color: SoloColors.successGreen,
                isLoading: viewModel.healthData == nil && viewModel.isLoading
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProfileInfoRow(
                title: "MEMBER SINCE",
                value: viewModel.profile?.formattedJoinDate ?? "Loading...",
                icon: "calendar"
            )

            Divider().background(Color.white.opacity(0.1))

            Button(action: {
                if let address = viewModel.profile?.walletAddress {
                    UIPasteboard.general.string = address
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }) {
                ProfileInfoRow(
                    title: "WALLET ADDRESS",
                    value: viewModel.shortAddress(viewModel.profile?.walletAddress),
                    icon: "doc.on.doc"
                )
            }
        }
        .liquidGlassCard(cornerRadius: DesignSystem.CornerRadius.large)
        .padding(.horizontal, DesignSystem.Spacing.xl)
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

// MARK: - Profile Stat Card

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
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Profile Info Row

struct ProfileInfoRow: View {
    let title: String
    let value: String
    var icon: String? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(SoloColors.textTertiary)
                    .tracking(1)
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            Spacer()
            if let iconName = icon {
                Image(systemName: iconName)
                    .foregroundColor(SoloColors.textTertiary)
                    .font(.system(size: 14))
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
