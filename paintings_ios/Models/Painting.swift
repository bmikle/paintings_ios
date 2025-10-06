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
    let imageURL: String
    let thumbnailURL: String?
    let description: String
    let museum: String
    let location: String
    let dimensions: String?
    let medium: String
    let wikiURL: String?

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
         imageURL: String,
         thumbnailURL: String? = nil,
         description: String,
         museum: String,
         location: String,
         dimensions: String? = nil,
         medium: String,
         wikiURL: String? = nil,
         isFavorite: Bool = false,
         isLearned: Bool = false,
         lastViewed: Date? = nil,
         timesViewed: Int = 0) {
        self.id = id
        self.title = title
        self.artist = artist
        self.year = year
        self.period = period
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.description = description
        self.museum = museum
        self.location = location
        self.dimensions = dimensions
        self.medium = medium
        self.wikiURL = wikiURL
        self.isFavorite = isFavorite
        self.isLearned = isLearned
        self.lastViewed = lastViewed
        self.timesViewed = timesViewed
    }
}

enum ArtPeriod: String, Codable, CaseIterable {
    case renaissance = "Renaissance"
    case baroque = "Baroque"
    case rococo = "Rococo"
    case neoclassicism = "Neoclassicism"
    case romanticism = "Romanticism"
    case realism = "Realism"
    case impressionism = "Impressionism"
    case postImpressionism = "Post-Impressionism"
    case expressionism = "Expressionism"
    case cubism = "Cubism"
    case surrealism = "Surrealism"
    case abstract = "Abstract"
    case modern = "Modern"
    case contemporary = "Contemporary"
    case other = "Other"
}

// MARK: - Sample Data Extension
extension Painting {
    static let sample = Painting(
        title: "Mona Lisa",
        artist: "Leonardo da Vinci",
        year: 1503,
        period: .renaissance,
        imageURL: "https://example.com/mona-lisa.jpg",
        description: "The Mona Lisa is a half-length portrait painting by Italian artist Leonardo da Vinci. Considered an archetypal masterpiece of the Italian Renaissance, it has been described as the best known, the most visited, the most written about, the most sung about, the most parodied work of art in the world.",
        museum: "Louvre Museum",
        location: "Paris, France",
        dimensions: "77 cm × 53 cm",
        medium: "Oil on poplar panel",
        wikiURL: "https://en.wikipedia.org/wiki/Mona_Lisa"
    )
}
