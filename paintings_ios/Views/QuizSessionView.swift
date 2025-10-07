//
//  QuizSessionView.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 07.10.2025.
//

import SwiftUI

enum QuizQuestionType {
    case paintingToPeriod  // Show painting, pick period name
    case periodToPainting  // Show period name, pick painting image
}

struct QuizQuestion {
    let type: QuizQuestionType
    let question: String
    let correctAnswer: String
    let allAnswers: [String]
    let paintingImageName: String?  // For paintingToPeriod type
    let answerImageNames: [String: String]?  // For periodToPainting type (answer text -> image name)
}

struct QuizSessionView: View {
    let quiz: PeriodsQuiz
    @ObservedObject var viewModel: PaintingsViewModel
    @ObservedObject var progressManager: QuizProgressManager

    @State private var questions: [QuizQuestion] = []
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String? = nil
    @State private var showingResult = false
    @State private var quizCompleted = false
    @Environment(\.dismiss) var dismiss

    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var body: some View {
        VStack(spacing: 20) {
            if quizCompleted {
                // Results screen
                VStack(spacing: 24) {
                    Text("Quiz Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    ZStack {
                        Circle()
                            .fill(scoreColor.opacity(0.2))
                            .frame(width: 150, height: 150)

                        VStack(spacing: 8) {
                            Text("\(score)")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundStyle(scoreColor)

                            Text("/ \(questions.count)")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(scoreMessage)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
                .padding()

            } else if let question = currentQuestion {
                // Question header
                VStack(spacing: 8) {
                    Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                        .padding(.horizontal)
                }
                .padding(.top)

                VStack(spacing: 0) {
                    // Top section with question and image
                    ScrollView {
                        VStack(spacing: 24) {
                            // Question
                            Text(question.question)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding()

                            // Painting image if available (for paintingToPeriod type)
                            if question.type == .paintingToPeriod, let imageName = question.paintingImageName {
                                AsyncImage(url: Bundle.main.url(forResource: imageName, withExtension: "jpg")) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
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
                                        .aspectRatio(4/3, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    Spacer()

                    // Bottom section with answer buttons
                    VStack(spacing: 16) {
                        // Answer choices in 2x2 grid
                        let answersArray = question.allAnswers
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                if answersArray.count > 0 {
                                    answerButton(for: answersArray[0])
                                }
                                if answersArray.count > 1 {
                                    answerButton(for: answersArray[1])
                                }
                            }

                            HStack(spacing: 12) {
                                if answersArray.count > 2 {
                                    answerButton(for: answersArray[2])
                                }
                                if answersArray.count > 3 {
                                    answerButton(for: answersArray[3])
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Next button
                        if showingResult {
                            Button(action: nextQuestion) {
                                Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "Finish Quiz")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
        .navigationTitle(quiz.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateQuestions()
        }
    }

    @ViewBuilder
    func answerButton(for answer: String) -> some View {
        Button(action: {
            if selectedAnswer == nil {
                selectAnswer(answer)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(answerBackground(for: answer))
                    .aspectRatio(1, contentMode: .fit)

                if currentQuestion?.type == .periodToPainting,
                   let imageNames = currentQuestion?.answerImageNames,
                   let imageName = imageNames[answer] {
                    // Show painting image for periodToPainting type
                    ZStack {
                        AsyncImage(url: Bundle.main.url(forResource: imageName, withExtension: "jpg")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure(_), .empty:
                                ZStack {
                                    Color.gray.opacity(0.2)
                                    Image(systemName: "photo.artframe")
                                        .font(.title3)
                                        .foregroundStyle(.gray)
                                }
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Overlay for result indicator
                        if showingResult {
                            Color.black.opacity(0.3)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            if answer == currentQuestion?.correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.green)
                            } else if answer == selectedAnswer {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                } else {
                    // Show text for paintingToPeriod type
                    VStack(spacing: 8) {
                        Text(answer)
                            .font(.headline)
                            .foregroundStyle(answerTextColor(for: answer))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)

                        if showingResult && answer == currentQuestion?.correctAnswer {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                        } else if showingResult && answer == selectedAnswer {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                }
            }
        }
        .disabled(selectedAnswer != nil)
    }

    func answerTextColor(for answer: String) -> Color {
        if !showingResult {
            return .primary
        }
        if answer == currentQuestion?.correctAnswer {
            return .green
        } else if answer == selectedAnswer {
            return .red
        }
        return .primary
    }

    func answerBackground(for answer: String) -> Color {
        if !showingResult {
            return Color.gray.opacity(0.1)
        }
        if answer == currentQuestion?.correctAnswer {
            return Color.green.opacity(0.2)
        } else if answer == selectedAnswer {
            return Color.red.opacity(0.2)
        }
        return Color.gray.opacity(0.1)
    }

    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        if answer == currentQuestion?.correctAnswer {
            score += 1
        }

        withAnimation {
            showingResult = true
        }
    }

    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showingResult = false
        } else {
            // Save progress when quiz is completed
            progressManager.completeQuiz(id: quiz.id, score: score, totalQuestions: questions.count)
            quizCompleted = true
        }
    }

    var scoreColor: Color {
        let percentage = Double(score) / Double(questions.count)
        if percentage >= 0.7 {
            return .green
        } else if percentage >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }

    var scoreMessage: String {
        let percentage = Double(score) / Double(questions.count)
        if percentage >= 0.8 {
            return "Great job! You passed and unlocked the next quiz! 🎉"
        } else {
            return "You need 80% to pass and unlock the next quiz. Keep practicing!"
        }
    }

    func generateQuestions() {
        var generatedQuestions: [QuizQuestion] = []
        let coveredPeriods = quiz.coversPeriods.compactMap { ArtPeriod(rawValue: $0) }
        let relevantPaintings = viewModel.paintings.filter { coveredPeriods.contains($0.period) }

        let questionsPerType = quiz.settings.questionsPerSession / 2  // 5 of each type

        // Generate painting-to-period questions (5)
        let shuffledPaintings = relevantPaintings.shuffled()
        for painting in shuffledPaintings.prefix(questionsPerType) {
            let correctPeriod = painting.period.displayName

            // Get wrong answers from other covered periods
            var wrongAnswers = coveredPeriods
                .filter { $0 != painting.period }
                .map { $0.displayName }
                .shuffled()
                .prefix(3)

            var allAnswers = Array(wrongAnswers) + [correctPeriod]
            allAnswers.shuffle()

            let question = QuizQuestion(
                type: .paintingToPeriod,
                question: "Which period is this painting from?",
                correctAnswer: correctPeriod,
                allAnswers: allAnswers,
                paintingImageName: painting.imageName,
                answerImageNames: nil
            )

            generatedQuestions.append(question)
        }

        // Generate period-to-painting questions (5)
        for period in coveredPeriods.shuffled().prefix(questionsPerType) {
            let periodPaintings = relevantPaintings.filter { $0.period == period }
            guard let correctPainting = periodPaintings.randomElement() else { continue }

            // Get wrong paintings from other periods
            let wrongPaintings = relevantPaintings
                .filter { $0.period != period }
                .shuffled()
                .prefix(3)

            var allPaintings = wrongPaintings + [correctPainting]
            allPaintings.shuffle()

            // Create a mapping of answer identifier to image name
            var answerImageNames: [String: String] = [:]
            for painting in allPaintings {
                answerImageNames[painting.title] = painting.imageName
            }

            let question = QuizQuestion(
                type: .periodToPainting,
                question: "Which painting is from \(period.displayName)?",
                correctAnswer: correctPainting.title,
                allAnswers: allPaintings.map { $0.title },
                paintingImageName: nil,
                answerImageNames: answerImageNames
            )

            generatedQuestions.append(question)
        }

        // Shuffle all questions together
        questions = generatedQuestions.shuffled()
    }
}
