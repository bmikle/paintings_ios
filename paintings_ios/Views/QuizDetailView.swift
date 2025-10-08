//
//  QuizDetailView.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 07.10.2025.
//

import SwiftUI

struct QuizDetailView: View {
    let quiz: PeriodsQuiz
    @ObservedObject var viewModel: PaintingsViewModel
    @ObservedObject var progressManager: QuizProgressManager
    @State private var selectedPainting: Painting?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(quiz.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Learn about: \(quiz.coversPeriods.compactMap { ArtPeriod(rawValue: $0)?.displayName }.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()

                // Lessons
                ForEach(Array(quiz.lessons.enumerated()), id: \.offset) { index, lesson in
                    VStack(alignment: .leading, spacing: 16) {
                        // Period Title
                        Text(lesson.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        // Description
                        Text(lesson.description)
                            .font(.body)
                            .padding(.horizontal)

                        // Key Characteristics
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Key Characteristics:")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(lesson.keyCharacteristics, id: \.self) { characteristic in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                    Text(characteristic)
                                        .font(.subheadline)
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Example Paintings
                        if !lesson.examplePaintingIds.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Examples:")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(lesson.examplePaintingIds, id: \.self) { paintingId in
                                            if let painting = viewModel.paintings.first(where: { $0.imageName == paintingId }) {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    AsyncImage(url: Bundle.main.url(forResource: painting.imageName, withExtension: "jpg")) { phase in
                                                        switch phase {
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 200, height: 200)
                                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        case .failure(_), .empty:
                                                            ZStack {
                                                                LinearGradient(
                                                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                )
                                                                Image(systemName: "photo.artframe")
                                                                    .font(.largeTitle)
                                                                    .foregroundStyle(.gray)
                                                            }
                                                            .frame(width: 200, height: 200)
                                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        @unknown default:
                                                            EmptyView()
                                                        }
                                                    }
                                                    .onTapGesture {
                                                        selectedPainting = painting
                                                    }

                                                    Text(painting.title)
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                        .lineLimit(2)
                                                        .frame(width: 200)

                                                    Text(painting.artist)
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                        .frame(width: 200)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        if index < quiz.lessons.count - 1 {
                            Divider()
                                .padding(.vertical, 8)
                        }
                    }
                }

                // Start Quiz Button
                NavigationLink(destination: QuizSessionView(quiz: quiz, viewModel: viewModel, progressManager: progressManager)) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        Text("Start Quiz")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
        }
        .navigationTitle("Lesson")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedPainting) { painting in
            FullScreenImageView(painting: painting, isPresented: Binding(
                get: { selectedPainting != nil },
                set: { if !$0 { selectedPainting = nil } }
            ))
        }
    }
}

// Full-screen image viewer
struct FullScreenImageView: View {
    let painting: Painting
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                    }
                    Spacer()
                }

                // Image
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    AsyncImage(url: Bundle.main.url(forResource: painting.imageName, withExtension: "jpg")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(scale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            scale = lastScale * value
                                        }
                                        .onEnded { _ in
                                            lastScale = scale
                                            // Limit zoom
                                            if scale < 1.0 {
                                                scale = 1.0
                                                lastScale = 1.0
                                            } else if scale > 5.0 {
                                                scale = 5.0
                                                lastScale = 5.0
                                            }
                                        }
                                )
                                .onTapGesture(count: 2) {
                                    // Double tap to reset zoom
                                    withAnimation {
                                        scale = 1.0
                                        lastScale = 1.0
                                    }
                                }
                        case .failure(_), .empty:
                            ZStack {
                                Color.gray.opacity(0.3)
                                Image(systemName: "photo.artframe")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.white)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // Painting info
                VStack(spacing: 8) {
                    Text(painting.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(painting.artist)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))

                    if let year = painting.year {
                        Text(year)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding()
                .background(Color.black.opacity(0.7))
            }
        }
    }
}
