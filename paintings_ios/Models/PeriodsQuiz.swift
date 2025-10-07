//
//  PeriodsQuiz.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 07.10.2025.
//

import Foundation

struct PeriodsQuizData: Codable {
    let quizzes: [PeriodsQuiz]
}

struct PeriodsQuiz: Identifiable, Codable {
    let id: String
    let title: String
    let type: String
    let coversPeriods: [String]
    let lessons: [PeriodLesson]
    let questionTypes: [QuestionType]
    let settings: QuizSettings
}

struct PeriodLesson: Codable {
    let period: String
    let title: String
    let description: String
    let keyCharacteristics: [String]
    let examplePaintingIds: [String]
}

struct QuestionType: Codable {
    let type: String
    let instruction: String
    let weight: Int
}

struct QuizSettings: Codable {
    let questionsPerSession: Int
    let minimumCorrectToPass: Int
    let showExplanations: Bool
}
