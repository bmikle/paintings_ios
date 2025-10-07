//
//  PeriodsQuizService.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 07.10.2025.
//

import Foundation

class PeriodsQuizService {
    func loadPeriodsQuizzes() async throws -> [PeriodsQuiz] {
        guard let url = Bundle.main.url(forResource: "periods_quizzes", withExtension: "json") else {
            throw NSError(domain: "PeriodsQuizService", code: 404, userInfo: [NSLocalizedDescriptionKey: "periods_quizzes.json not found"])
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let quizData = try decoder.decode(PeriodsQuizData.self, from: data)
        return quizData.quizzes
    }
}
