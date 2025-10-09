//
//  PaintingsDataService.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 06.10.2025.
//

import Foundation

// MARK: - Response Models
struct PaintingsResponse: Codable {
    let paintings: [Painting]
}

// MARK: - Error Types
enum DataServiceError: Error {
    case fileNotFound
    case decodingError
    case savingError
}

class PaintingsDataService {
    static let shared = PaintingsDataService()

    private init() {}

    // Load paintings from bundled JSON files (one per period)
    func loadPaintings() async throws -> [Painting] {
        let periodFiles = [
            "renaissance",
            "baroque",
            "rococo",
            "neoclassicism",
            "realism",
            "impressionism",
            "post-impressionism",
            "expressionism",
            "cubism",
            "surrealism",
            "abstract_expressionism",
            "futurism",
            "minimalism",
            "pop_art",
            "symbolism",
            "contemporary_conceptual_art"
        ]

        var allPaintings: [Painting] = []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for periodFile in periodFiles {
            guard let url = Bundle.main.url(
                forResource: periodFile,
                withExtension: "json",
                subdirectory: "Data/Periods"
            ) else {
                print("⚠️ Warning: Could not find \(periodFile).json")
                continue
            }

            do {
                let data = try Data(contentsOf: url)
                let response = try decoder.decode(PaintingsResponse.self, from: data)
                allPaintings.append(contentsOf: response.paintings)
            } catch {
                print("⚠️ Warning: Could not decode \(periodFile).json - \(error)")
            }
        }

        guard !allPaintings.isEmpty else {
            throw DataServiceError.fileNotFound
        }

        return allPaintings
    }

    // Save paintings to local storage
    func savePaintings(_ paintings: [Painting]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let response = PaintingsResponse(paintings: paintings)
        let data = try encoder.encode(response)

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("paintings.json")

        try data.write(to: fileURL)
    }

    // Load paintings from local storage
    func loadLocalPaintings() throws -> [Painting] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("paintings.json")

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(PaintingsResponse.self, from: data)
        return response.paintings
    }

    // Search paintings
    func searchPaintings(_ paintings: [Painting], query: String) -> [Painting] {
        guard !query.isEmpty else { return paintings }

        return paintings.filter { painting in
            painting.title.localizedCaseInsensitiveContains(query) ||
            painting.artist.localizedCaseInsensitiveContains(query) ||
            painting.museum.localizedCaseInsensitiveContains(query)
        }
    }

    // Filter by period
    func filterByPeriod(_ paintings: [Painting], period: ArtPeriod) -> [Painting] {
        paintings.filter { $0.period == period }
    }

    // Filter by artist
    func filterByArtist(_ paintings: [Painting], artist: String) -> [Painting] {
        paintings.filter { $0.artist == artist }
    }
}
