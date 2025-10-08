//
//  SettingsView.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 08.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var progressManager = QuizProgressManager()
    @State private var showingResetAlert = false

    var body: some View {
        List {
            Section {
                Button(role: .destructive, action: {
                    showingResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                        Text("Reset Progress")
                    }
                }
            } header: {
                Text("Quiz Progress")
            } footer: {
                Text("This will reset all quiz progress and lock all quizzes except the first one. This action cannot be undone.")
            }
        }
        .navigationTitle("Settings")
        .alert("Reset Progress?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                progressManager.resetProgress()
            }
        } message: {
            Text("This will reset all your quiz progress. Are you sure?")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
