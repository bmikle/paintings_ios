//
//  ContentView.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 06.10.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PaintingsViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                QuizView(viewModel: viewModel)
            }
            .tabItem {
                Label("Quiz", systemImage: "brain.head.profile")
            }

            NavigationStack {
                PeriodsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Periods", systemImage: "calendar.badge.clock")
            }

            NavigationStack {
                ArtistsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Artists", systemImage: "paintpalette")
            }
        }
    }
}

#Preview {
    ContentView()
}
