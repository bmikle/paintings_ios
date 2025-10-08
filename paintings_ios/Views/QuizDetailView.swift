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
    @State private var currentLessonIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<quiz.lessons.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentLessonIndex ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 4)

            TabView(selection: $currentLessonIndex) {
                ForEach(Array(quiz.lessons.enumerated()), id: \.offset) { index, lesson in
                    lessonView(lesson: lesson, index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(quiz.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedPainting) { painting in
            FullScreenImageView(painting: painting, isPresented: Binding(
                get: { selectedPainting != nil },
                set: { if !$0 { selectedPainting = nil } }
            ))
        }
    }

    @ViewBuilder
    private func lessonView(lesson: PeriodLesson, index: Int) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Period Title
                    Text(lesson.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)

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

                    Spacer(minLength: 100)
                }
            }

            // Bottom button
            VStack(spacing: 0) {
                Divider()

                if index < quiz.lessons.count - 1 {
                    // Next button
                    Button(action: {
                        withAnimation {
                            currentLessonIndex += 1
                        }
                    }) {
                        HStack {
                            Text("Next")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding()
                } else {
                    // Start Quiz button (last lesson)
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
            .background(Color(UIColor.systemBackground))
        }
    }
}

// Full-screen image viewer
struct FullScreenImageView: View {
    let painting: Painting
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Image
            GeometryReader { geometry in
                AsyncImage(url: Bundle.main.url(forResource: painting.imageName, withExtension: "jpg")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                        // Limit zoom
                                        if scale < 1.0 {
                                            withAnimation {
                                                scale = 1.0
                                                lastScale = 1.0
                                                offset = .zero
                                                lastOffset = .zero
                                            }
                                        } else if scale > 5.0 {
                                            scale = 5.0
                                            lastScale = 5.0
                                        }
                                    }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if scale > 1.0 {
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .onTapGesture(count: 2) {
                                // Double tap to reset zoom
                                withAnimation {
                                    scale = 1.0
                                    lastScale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                    case .failure(_), .empty:
                        ZStack {
                            Color.gray.opacity(0.3)
                            Image(systemName: "photo.artframe")
                                .font(.system(size: 80))
                                .foregroundStyle(.white)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .ignoresSafeArea()

            // Close button overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 44, height: 44)

                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            .zIndex(10)
            .allowsHitTesting(true)
        }
    }
}
