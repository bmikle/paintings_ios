//
//  QuizProgress.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 07.10.2025.
//

import Foundation
internal import Combine

struct QuizProgress: Codable {
    var completedQuizIds: Set<String> = []
    var quizScores: [String: Int] = [:]  // quizId -> score (out of total questions)
    var unlockedQuizIds: Set<String> = ["periods-quiz-1"]  // First quiz is unlocked by default

    mutating func completeQuiz(id: String, score: Int, totalQuestions: Int, passed: Bool) {
        completedQuizIds.insert(id)
        quizScores[id] = score

        print("📝 Quiz completed: \(id), Score: \(score)/\(totalQuestions), Passed: \(passed)")

        // If passed with 80%+, unlock next quiz
        if passed {
            unlockNextQuiz(after: id)
        }
    }

    mutating func unlockNextQuiz(after quizId: String) {
        // Extract quiz number and unlock next one
        if let currentNumber = extractQuizNumber(from: quizId) {
            let nextQuizId = "periods-quiz-\(currentNumber + 1)"
            unlockedQuizIds.insert(nextQuizId)
            print("🔓 Unlocked next quiz: \(nextQuizId)")
            print("   All unlocked quizzes: \(unlockedQuizIds)")
        } else {
            print("⚠️ Could not extract quiz number from: \(quizId)")
        }
    }

    func isUnlocked(_ quizId: String) -> Bool {
        return unlockedQuizIds.contains(quizId)
    }

    func isCompleted(_ quizId: String) -> Bool {
        return completedQuizIds.contains(quizId)
    }

    func getScore(for quizId: String) -> Int? {
        return quizScores[quizId]
    }

    private func extractQuizNumber(from quizId: String) -> Int? {
        let components = quizId.split(separator: "-")
        if let lastComponent = components.last, let number = Int(lastComponent) {
            return number
        }
        return nil
    }
}

class QuizProgressManager: ObservableObject {
    @Published var progress: QuizProgress

    private let userDefaultsKey = "quiz_progress"

    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(QuizProgress.self, from: data) {
            self.progress = decoded
        } else {
            self.progress = QuizProgress()
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    func completeQuiz(id: String, score: Int, totalQuestions: Int) {
        let percentage = Double(score) / Double(totalQuestions)
        let passed = percentage >= 0.8

        // Create a copy to trigger @Published update
        var updatedProgress = progress
        updatedProgress.completeQuiz(id: id, score: score, totalQuestions: totalQuestions, passed: passed)
        progress = updatedProgress

        save()
    }

    func isUnlocked(_ quizId: String) -> Bool {
        return progress.isUnlocked(quizId)
    }

    func resetProgress() {
        progress = QuizProgress()
        save()
    }
}
