//
//  ProfileView.swift
//  dev-aasdf
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var profile: UserProfile?
    @State private var username: String = ""
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    // Image Picker States
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var inputImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // Danger Zone
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isLoading && profile == nil {
                ProgressView()
                    .tint(.white)
            } else {
                ScrollView {
                    VStack(spacing: 30) {
                        // MARK: - Profile Picture
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .stroke(Color(red: 0.2, green: 0.2, blue: 0.3), lineWidth: 2)
                                    .frame(width: 154, height: 154)
                                
                                if let urlString = profile?.profilePicUrl, let url = URL(string: urlString) {
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
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .frame(width: 150, height: 150)
                                }
                                
                                // Edit Overlay
                                Button(action: { showActionSheet = true }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16))
                                    }
                                }
                                .offset(x: 50, y: 50)
                            }
                            
                            Text("Hunter Rank: E") // Placeholder for future stats
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Username Edit
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CODENAME")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            HStack {
                                TextField("Username", text: $username)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else if username != profile?.username && !username.isEmpty {
                                    Button("SAVE") {
                                        Task { await updateUsername() }
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6).opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Info Section
                        VStack(spacing: 16) {
                            InfoRow(title: "MEMBER SINCE", value: profile?.formattedJoinDate ?? "Loading...")
                            
                            Button(action: {
                                if let address = profile?.walletAddress {
                                    UIPasteboard.general.string = address
                                    // Optional: Show toast
                                }
                            }) {
                                InfoRow(title: "WALLET ADDRESS", value: shortAddress(profile?.walletAddress), icon: "doc.on.doc")
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6).opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                        
                        // MARK: - Danger Zone
                        Button(action: { showDeleteConfirmation = true }) {
                            Text("Deactivate Account")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await loadProfile()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
        .confirmationDialog("Change Profile Picture", isPresented: $showActionSheet) {
            Button("Camera") {
                sourceType = .camera
                showImagePicker = true
            }
            Button("Photo Library") {
                sourceType = .photoLibrary
                showImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage, sourceType: sourceType)
                .ignoresSafeArea()
        }
        .onChange(of: inputImage) { newImage in
            if let img = newImage {
                Task { await uploadImage(img) }
            }
        }
        .alert("Deactivate Account?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Deactivate", role: .destructive) {
                Task { await deactivateAccount() }
            }
        } message: {
            Text("This action cannot be undone. You will be logged out immediately.")
        }
    }
    
    // MARK: - Logic
    
    private func loadProfile() async {
        isLoading = true
        do {
            let userProfile = try await APIService.shared.fetchMyProfile()
            self.profile = userProfile
            self.username = userProfile.username
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    private func updateUsername() async {
        guard !username.isEmpty else { return }
        isSaving = true
        do {
            let updatedProfile = try await APIService.shared.updateUsername(username)
            self.profile = updatedProfile
        } catch {
            errorMessage = "Username taken or invalid."
            showError = true
        }
        isSaving = false
    }
    
    private func uploadImage(_ image: UIImage) async {
        isLoading = true
        do {
            try await APIService.shared.uploadProfilePic(image)
            // Refresh profile to get new URL
            await loadProfile()
        } catch {
            errorMessage = "Failed to upload image."
            showError = true
            isLoading = false
        }
    }
    
    private func deactivateAccount() async {
        isLoading = true
        do {
            try await APIService.shared.deactivateAccount()
            authViewModel.logout()
        } catch {
            errorMessage = "Failed to deactivate account."
            showError = true
            isLoading = false
        }
    }
    
    private func shortAddress(_ address: String?) -> String {
        guard let addr = address, addr.count > 10 else { return address ?? "..." }
        return "\(addr.prefix(6))...\(addr.suffix(4))"
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    var icon: String? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
                    .foregroundColor(.white)
            }
            Spacer()
            if let iconName = icon {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
            }
        }
    }
}
