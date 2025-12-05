//
//  ProfileView.swift
//  dev-aasdf
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @FocusState private var isUsernameFocused: Bool

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            // Ambient Glow
            Circle()
                .fill(Color.blue.opacity(0.1))
                .blur(radius: 100)
                .offset(x: 100, y: -200)

            if viewModel.isLoading && viewModel.profile == nil {
                ProgressView()
                    .tint(.white)
            } else {
                ScrollView {
                    VStack(spacing: 30) {
                        // MARK: - Profile Header
                        VStack(spacing: 20) {
                            // Profile Picture
                            ZStack {
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 124, height: 124)

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
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .id(urlString)  // Force reload when URL changes (cache busting)
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .frame(width: 120, height: 120)
                                }

                                // Edit Button
                                Button(action: { viewModel.showActionSheet = true }) {
                                    ZStack {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Circle().stroke(
                                                    Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                    }
                                }
                                .offset(x: 40, y: 40)
                            }

                            // Username / Codename
                            VStack(spacing: 8) {
                                Text("CODENAME")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .tracking(2)

                                HStack {
                                    TextField("Username", text: $viewModel.username)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 24, weight: .bold))
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
                                                .foregroundColor(.green)
                                                .font(.title3)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)

                        // MARK: - Stats Row
                        HStack(spacing: 12) {
                            StatCardView(
                                title: "Intel",
                                value: viewModel.intelligenceData.map {
                                    if let score = $0.intelligenceTotalScore {
                                        return String(Int(score))
                                    } else {
                                        return "—"
                                    }
                                } ?? "—",
                                accentColor: .blue,
                                isLoading: viewModel.intelligenceData == nil && viewModel.isLoading
                            )

                            StatCardView(
                                title: "Strength",
                                value: viewModel.strengthData.map {
                                    String(Int($0.strengthTotalScore))
                                } ?? "—",
                                accentColor: .red,
                                isLoading: viewModel.strengthData == nil && viewModel.isLoading
                            )

                            StatCardView(
                                title: "Discipline",
                                value: viewModel.disciplineData.map {
                                    if let score = $0.disciplineTotalScore {
                                        return String(Int(score))
                                    } else {
                                        return "—"
                                    }
                                } ?? "—",
                                accentColor: .purple,
                                isLoading: viewModel.disciplineData == nil && viewModel.isLoading
                            )

                            StatCardView(
                                title: "Health",
                                value: viewModel.healthData.map {
                                    if let score = $0.healthTotalScore {
                                        return String(Int(score))
                                    } else {
                                        return "—"
                                    }
                                } ?? "—",
                                accentColor: .green,
                                isLoading: viewModel.healthData == nil && viewModel.isLoading
                            )
                        }
                        .padding(.horizontal)

                        // MARK: - Info Section
                        VStack(spacing: 16) {
                            InfoRow(
                                title: "MEMBER SINCE",
                                value: viewModel.profile?.formattedJoinDate ?? "Loading...")

                            Divider().background(Color.white.opacity(0.1))

                            Button(action: {
                                if let address = viewModel.profile?.walletAddress {
                                    UIPasteboard.general.string = address
                                    // Optional: Show toast
                                }
                            }) {
                                InfoRow(
                                    title: "WALLET ADDRESS",
                                    value: viewModel.shortAddress(viewModel.profile?.walletAddress),
                                    icon: "doc.on.doc")
                            }
                        }
                        .padding(20)
                        .glassCard(cornerRadius: 24)
                        .padding(.horizontal)

                        Spacer(minLength: 40)

                        // MARK: - Danger Zone
                        Button(action: { viewModel.showDeleteConfirmation = true }) {
                            Text("Deactivate Account")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red.opacity(0.8))
                                .padding()
                                .background(
                                    Capsule()
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 40)
                    }
                }
                .refreshable {
                    await viewModel.reloadProfile()
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            // Only load if not already loaded to prevent flickering on re-appear
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
        .onChange(of: viewModel.inputImage) { newImage in
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
}

struct InfoRow: View {
    let title: String
    let value: String
    var icon: String? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1)
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            Spacer()
            if let iconName = icon {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
        }
    }
}
