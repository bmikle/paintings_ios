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
    case renaissance = "renaissance"
    case baroque = "baroque"
    case rococo = "rococo"
    case neoclassicism = "neoclassicism"
    case romanticism = "romanticism"
    case realism = "realism"
    case impressionism = "impressionism"
    case postImpressionism = "postImpressionism"
    case expressionism = "expressionism"
    case cubism = "cubism"
    case surrealism = "surrealism"
    case abstract = "abstract"
    case modern = "modern"
    case contemporary = "contemporary"
    case other = "other"

    // Display name for UI
    var displayName: String {
        switch self {
        case .renaissance: return "Renaissance"
        case .baroque: return "Baroque"
        case .rococo: return "Rococo"
        case .neoclassicism: return "Neoclassicism"
        case .romanticism: return "Romanticism"
        case .realism: return "Realism"
        case .impressionism: return "Impressionism"
        case .postImpressionism: return "Post-Impressionism"
        case .expressionism: return "Expressionism"
        case .cubism: return "Cubism"
        case .surrealism: return "Surrealism"
        case .abstract: return "Abstract"
        case .modern: return "Modern"
        case .contemporary: return "Contemporary"
        case .other: return "Other"
        }
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
