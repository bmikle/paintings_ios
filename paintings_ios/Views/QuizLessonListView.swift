//
//  QuizLessonListView.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 07.10.2025.
//

import SwiftUI

struct QuizLessonListView: View {
    @ObservedObject var viewModel: PaintingsViewModel
    @StateObject private var progressManager = QuizProgressManager()
    let lessonType: LessonType
    @State private var periodsQuizzes: [PeriodsQuiz] = []
    @State private var isLoading = true

    enum LessonType {
        case allPeriods
        case specificPeriod(ArtPeriod)
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading quizzes...")
            } else {
                List {
                    switch lessonType {
                    case .allPeriods:
                        ForEach(periodsQuizzes) { quiz in
                            let isUnlocked = progressManager.isUnlocked(quiz.id)
                            let isCompleted = progressManager.progress.isCompleted(quiz.id)

                            Group {
                                if isUnlocked {
                                    NavigationLink(destination: QuizDetailView(quiz: quiz, viewModel: viewModel, progressManager: progressManager)) {
                                        quizRow(quiz: quiz, isUnlocked: true, isCompleted: isCompleted)
                                    }
                                } else {
                                    Button(action: {}) {
                                        quizRow(quiz: quiz, isUnlocked: false, isCompleted: false)
                                    }
                                    .disabled(true)
                                }
                            }
                        }

                    case .specificPeriod(let period):
                        Text("Quiz for \(period.displayName) - Coming Soon")
                    }
                }
            }
        }
        .navigationTitle(navigationTitle)
        .task {
            await loadQuizzes()
        }
    }

    var navigationTitle: String {
        switch lessonType {
        case .allPeriods:
            return "Art Periods"
        case .specificPeriod(let period):
            return period.displayName
        }
    }

    @ViewBuilder
    func quizRow(quiz: PeriodsQuiz, isUnlocked: Bool, isCompleted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    LinearGradient(
                        colors: isUnlocked ? [Color.blue, Color.purple] : [Color.gray, Color.gray.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    if isUnlocked {
                        Text(quiz.title.replacingOccurrences(of: "Quiz ", with: ""))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(quiz.title)
                            .font(.headline)
                            .foregroundStyle(isUnlocked ? .primary : .secondary)

                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }

                    Text(quiz.coversPeriods.compactMap { periodString in
                        ArtPeriod(rawValue: periodString)?.displayName
                    }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    if !isUnlocked {
                        Text("Complete previous quiz to unlock")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }

                Spacer()
            }
        }
        .padding(.vertical, 4)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }

    func loadQuizzes() async {
        let service = PeriodsQuizService()
        do {
            periodsQuizzes = try await service.loadPeriodsQuizzes()
        } catch {
            print("Error loading quizzes: \(error)")
        }
        isLoading = false
    }
}
