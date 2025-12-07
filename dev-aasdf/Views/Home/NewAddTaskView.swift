//
//  NewAddTaskView.swift
//  The "+" screen for adding tasks - NEW REDESIGN
//

import SwiftUI

struct NewAddTaskView: View {
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var selectedPriority = "Medium"
    
    let priorities = ["Low", "Medium", "High", "Critical"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.shadowBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        Text("New Quest")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color.shadowText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                        
                        // Task title input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TITLE")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.shadowTextSecondary)
                                .tracking(1)
                            
                            TextField("Enter quest title", text: $taskTitle)
                                .textFieldStyle(GlassTextFieldStyle())
                        }
                        
                        // Description input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIPTION")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.shadowTextSecondary)
                                .tracking(1)
                            
                            TextField("Enter details", text: $taskDescription, axis: .vertical)
                                .textFieldStyle(GlassTextFieldStyle())
                                .lineLimit(4...8)
                        }
                        
                        // Priority selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PRIORITY")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.shadowTextSecondary)
                                .tracking(1)
                            
                            HStack(spacing: 12) {
                                ForEach(priorities, id: \.self) { priority in
                                    Button {
                                        selectedPriority = priority
                                    } label: {
                                        Text(priority)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(
                                                selectedPriority == priority ? Color.shadowText : Color.shadowTextSecondary
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .liquidGlass(cornerRadius: 12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        selectedPriority == priority ? Color.violetGlow : Color.clear,
                                                        lineWidth: 2
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Create button
                        Button {
                            createTask()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Create Quest")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [.violetGlow, .violetGlow.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .violetGlow()
                        }
                        .disabled(taskTitle.isEmpty)
                        .opacity(taskTitle.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func createTask() {
        // Handle task creation
        print("Creating task: \(taskTitle)")
        
        // Reset form
        taskTitle = ""
        taskDescription = ""
        selectedPriority = "Medium"
    }
}

#Preview {
    NewAddTaskView()
}
