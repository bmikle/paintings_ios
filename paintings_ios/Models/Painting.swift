//
//  Painting.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 06.10.2025.
//

import Foundation

struct Painting: Identifiable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let year: Int
    let period: ArtPeriod
    let imageName: String  // Name of image file in bundle (without extension)
    let museum: String
    let location: String

    // Learning-related properties
    var isFavorite: Bool = false
    var isLearned: Bool = false
    var lastViewed: Date?
    var timesViewed: Int = 0

    init(id: UUID = UUID(),
         title: String,
         artist: String,
         year: Int,
         period: ArtPeriod,
         imageName: String,
         museum: String,
         location: String,
         isFavorite: Bool = false,
         isLearned: Bool = false,
         lastViewed: Date? = nil,
         timesViewed: Int = 0) {
        self.id = id
        self.title = title
        self.artist = artist
        self.year = year
        self.period = period
        self.imageName = imageName
        self.museum = museum
        self.location = location
        self.isFavorite = isFavorite
        self.isLearned = isLearned
        self.lastViewed = lastViewed
        self.timesViewed = timesViewed
    }

    // Custom Codable implementation to handle optional learning properties
    enum CodingKeys: String, CodingKey {
        case id, title, artist, year, period, imageName
        case museum, location
        case isFavorite, isLearned, lastViewed, timesViewed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode required fields
        let idString = try container.decode(String.self, forKey: .id)
        id = UUID(uuidString: idString) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        year = try container.decode(Int.self, forKey: .year)
        period = try container.decode(ArtPeriod.self, forKey: .period)
        imageName = try container.decode(String.self, forKey: .imageName)
        museum = try container.decode(String.self, forKey: .museum)
        location = try container.decode(String.self, forKey: .location)

        // Decode learning properties with defaults
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        isLearned = try container.decodeIfPresent(Bool.self, forKey: .isLearned) ?? false
        lastViewed = try container.decodeIfPresent(Date.self, forKey: .lastViewed)
        timesViewed = try container.decodeIfPresent(Int.self, forKey: .timesViewed) ?? 0
    }
}

enum ArtPeriod: String, Codable, CaseIterable {
    case renaissance = "Renaissance"
    case baroque = "Baroque"
    case rococo = "Rococo"
    case neoclassicism = "Neoclassicism"
    case realism = "Realism"
    case impressionism = "Impressionism"
    case postImpressionism = "Post-Impressionism"
    case expressionism = "Expressionism"
    case cubism = "Cubism"
    case surrealism = "Surrealism"
    case abstractExpressionism = "Abstract Expressionism"
    case futurism = "Futurism"
    case minimalism = "Minimalism"
    case popArt = "Pop Art"
    case symbolism = "Symbolism"
    case contemporaryConceptual = "Contemporary / Conceptual Art"

    // Display name for UI
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Sample Data Extension
extension Painting {
    static let sample = Painting(
        title: "Mona Lisa",
        artist: "Leonardo da Vinci",
        year: 1503,
        period: .renaissance,
        imageName: "mona_lisa",
        museum: "Louvre Museum",
        location: "Paris, France"
    )
}
