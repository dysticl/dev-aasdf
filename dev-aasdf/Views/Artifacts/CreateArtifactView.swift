//
//  CreateArtifactView.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 06.12.25.
//

import SwiftUI

struct CreateArtifactView: View {
    @ObservedObject var viewModel: ArtifactsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var taskName = ""
    @State private var description = ""
    @State private var selectedCategory = "Education"
    @State private var estimatedHours = 1.0
    @State private var priority = "medium"
    @State private var deadline = Date()
    @State private var showDeadline = false

    // For handling submission loading
    @State private var isSubmitting = false

    let priorities = ["low", "medium", "high", "critical"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        taskInputSection
                        descriptionSection
                        categorySection
                        estimatedHoursSection
                        prioritySection
                        submitButton
                    }
                    .padding()
                }
            }
            .navigationTitle("New Artifact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Subviews

    private var taskInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Task Name")
                .foregroundColor(.gray)
            TextField("Read 20 pages", text: $taskName)
                .textFieldStyle(GlassTextFieldStyle())
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .foregroundColor(.gray)
            TextField("Details...", text: $description, axis: .vertical)
                .textFieldStyle(GlassTextFieldStyle())
                .lineLimit(3...6)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .foregroundColor(.gray)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.categories) { category in
                        Button {
                            selectedCategory = category.name
                        } label: {
                            VStack {
                                Text(category.iconUrl)
                                    .font(.title)
                                Text(category.name)
                                    .font(.caption)
                            }
                            .padding()
                            .frame(width: 80, height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        selectedCategory == category.name
                                            ? AnyShapeStyle(Color.blue.opacity(0.3))
                                            : AnyShapeStyle(Material.ultraThinMaterial)
                                    )
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedCategory == category.name
                                            ? Color.blue : Color.white.opacity(0.1),
                                        lineWidth: 1)
                            )
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private var estimatedHoursSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Estimated Hours")
                    .foregroundColor(.gray)
                Spacer()
                Text(String(format: "%.1f h", estimatedHours))
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            Slider(value: $estimatedHours, in: 0.5...10, step: 0.5)
        }
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Priority")
                .foregroundColor(.gray)
            Picker("Priority", selection: $priority) {
                ForEach(priorities, id: \.self) { p in
                    Text(p.capitalized).tag(p)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var submitButton: some View {
        Button {
            Task {
                isSubmitting = true
                let success = await viewModel.createArtifact(
                    taskName: taskName,
                    description: description,
                    category: selectedCategory,
                    estimatedHours: estimatedHours,
                    priority: priority,
                    deadline: showDeadline ? deadline : nil
                )
                isSubmitting = false
                if success {
                    dismiss()
                }
            }
        } label: {
            HStack {
                if isSubmitting || viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create & Get Estimate")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(taskName.isEmpty || isSubmitting)
        .opacity(taskName.isEmpty ? 0.5 : 1)
    }
}

struct GlassTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Material.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}
