//
//  PaintingsDataService.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 06.10.2025.
//

import Foundation

class PaintingsDataService {
    static let shared = PaintingsDataService()

    private init() {}

    // Load paintings from JSON file or API
    func loadPaintings() async throws -> [Painting] {
        // TODO: Implement loading from JSON file or API
        // For now, return empty array
        return []
    }

    // Save paintings to local storage
    func savePaintings(_ paintings: [Painting]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(paintings)

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

        return try decoder.decode([Painting].self, from: data)
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
