//
//  ContentView.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 06.10.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PaintingsViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Quiz Button - Large
                NavigationLink(destination: QuizView(viewModel: viewModel)) {
                    VStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundStyle(.white)

                        Text("Quiz")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Test your knowledge")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)

                // Periods and Artists Buttons - Side by side
                HStack(spacing: 16) {
                    NavigationLink(destination: PeriodsView(viewModel: viewModel)) {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 40))
                                .foregroundStyle(.white)

                            Text("Periods")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: ArtistsView(viewModel: viewModel)) {
                        VStack(spacing: 8) {
                            Image(systemName: "paintpalette")
                                .font(.system(size: 40))
                                .foregroundStyle(.white)

                            Text("Artists")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Famous Paintings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(viewModel.paintings.count) paintings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
