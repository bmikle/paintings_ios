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

    // Load paintings from bundled JSON file
    func loadPaintings() async throws -> [Painting] {
        guard let url = Bundle.main.url(forResource: "paintings", withExtension: "json") else {
            throw DataServiceError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(PaintingsResponse.self, from: data)
        return response.paintings
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
