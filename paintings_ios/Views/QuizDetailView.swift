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
    }
}
