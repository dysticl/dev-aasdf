//
//  UploadProofView.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 06.12.25.
//

import PhotosUI
import SwiftUI
import UIKit

struct UploadProofView: View {
    let artifactId: String
    @ObservedObject var viewModel: ArtifactsViewModel
    let onComplete: (CompletionResponse) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var actualHours: Double = 1.0
    @State private var userNote: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isUploading = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Text("Missions Report")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        // MARK: - Hours Input
                        VStack(alignment: .leading) {
                            Text("Time Spent")
                                .foregroundColor(.gray)
                            HStack {
                                Text(String(format: "%.1f hours", actualHours))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                Stepper("", value: $actualHours, in: 0.1...24, step: 0.1)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Material.ultraThinMaterial)
                            .cornerRadius(12)
                        }

                        // MARK: - Proof Upload
                        VStack(alignment: .leading) {
                            Text("Proof of Work")
                                .foregroundColor(.gray)

                            VStack {
                                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(12)
                                        .clipped()
                                } else {
                                    PhotosPicker(selection: $selectedItem, matching: .images) {
                                        VStack {
                                            Image(systemName: "camera.fill")
                                                .font(.largeTitle)
                                            Text("Select Photo")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 150)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                                .foregroundColor(.gray)
                                        )
                                    }
                                }
                            }
                        }

                        // MARK: - User Note
                        VStack(alignment: .leading) {
                            Text("Debrief Note")
                                .foregroundColor(.gray)
                            TextField("Optional note...", text: $userNote, axis: .vertical)
                                .padding()
                                .background(Material.ultraThinMaterial)
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .lineLimit(3)
                        }

                        Spacer()

                        // MARK: - Submit Button
                        Button {
                            submitProof()
                        } label: {
                            HStack {
                                if isUploading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Submit & Complete")
                                        .fontWeight(.bold)
                                    Image(systemName: "paperplane.fill")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .disabled(isUploading)

                    }
                    .padding()
                }
            }
            .navigationTitle("Complete Mission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }

    func submitProof() {
        guard !isUploading else { return }
        isUploading = true

        Task {
            // 1. Upload Proof if exists
            if let data = selectedImageData {
                let success = await viewModel.uploadProof(
                    artifactId: artifactId,
                    files: [(data: data, mimeType: "image/jpeg", filename: "proof.jpg")],
                    actualHours: actualHours
                )
                if !success {
                    isUploading = false
                    return
                }
            }

            // 2. Complete Artifact
            if let response = await viewModel.completeArtifact(
                artifactId: artifactId,
                actualHours: actualHours,
                userNote: userNote
            ) {
                isUploading = false
                dismiss()  // Dismiss upload sheet
                onComplete(response)  // Trigget completion view in parent
            } else {
                isUploading = false
            }
        }
    }
}
