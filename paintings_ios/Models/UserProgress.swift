//
//  UserProgress.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 06.10.2025.
//

import Foundation

struct UserProgress: Codable {
    var learnedPaintings: Set<UUID> = []
    var favoritePaintings: Set<UUID> = []
    var paintingViewCounts: [UUID: Int] = [:]
    var lastViewedDates: [UUID: Date] = [:]
    var quizScores: [QuizResult] = []

    var totalLearned: Int {
        learnedPaintings.count
    }

    var progressPercentage: Double {
        Double(learnedPaintings.count) / 1000.0 * 100
    }
}

struct QuizResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let score: Int
    let totalQuestions: Int
    let paintingsQuizzed: [UUID]

    var percentage: Double {
        Double(score) / Double(totalQuestions) * 100
    }

    init(id: UUID = UUID(), date: Date = Date(), score: Int, totalQuestions: Int, paintingsQuizzed: [UUID]) {
        self.id = id
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
        self.paintingsQuizzed = paintingsQuizzed
    }
}
