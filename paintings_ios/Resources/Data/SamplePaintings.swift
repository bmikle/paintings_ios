//
//  SamplePaintings.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 06.10.2025.
//

import Foundation

struct SamplePaintings {
    static let all: [Painting] = [
        Painting(
            title: "Mona Lisa",
            artist: "Leonardo da Vinci",
            year: 1503,
            period: .renaissance,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/800px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg",
            description: "The Mona Lisa is a half-length portrait painting by Italian artist Leonardo da Vinci. Considered an archetypal masterpiece of the Italian Renaissance, it has been described as the best known, the most visited, the most written about, the most sung about, the most parodied work of art in the world.",
            museum: "Louvre Museum",
            location: "Paris, France",
            dimensions: "77 cm × 53 cm",
            medium: "Oil on poplar panel",
            wikiURL: "https://en.wikipedia.org/wiki/Mona_Lisa"
        ),
        Painting(
            title: "The Starry Night",
            artist: "Vincent van Gogh",
            year: 1889,
            period: .postImpressionism,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/1280px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg",
            description: "The Starry Night is an oil-on-canvas painting by Dutch Post-Impressionist painter Vincent van Gogh. Painted in June 1889, it depicts the view from the east-facing window of his asylum room at Saint-Rémy-de-Provence, just before sunrise, with the addition of an imaginary village.",
            museum: "Museum of Modern Art",
            location: "New York City, USA",
            dimensions: "73.7 cm × 92.1 cm",
            medium: "Oil on canvas",
            wikiURL: "https://en.wikipedia.org/wiki/The_Starry_Night"
        ),
        Painting(
            title: "The Last Supper",
            artist: "Leonardo da Vinci",
            year: 1498,
            period: .renaissance,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/%C3%9Altima_Cena_-_Da_Vinci_5.jpg/1280px-%C3%9Altima_Cena_-_Da_Vinci_5.jpg",
            description: "The Last Supper is a mural painting by Italian High Renaissance artist Leonardo da Vinci. It depicts the scene of the Last Supper of Jesus with the Twelve Apostles, as it is told in the Gospel of John.",
            museum: "Santa Maria delle Grazie",
            location: "Milan, Italy",
            dimensions: "460 cm × 880 cm",
            medium: "Tempera on gesso, pitch, and mastic",
            wikiURL: "https://en.wikipedia.org/wiki/The_Last_Supper_(Leonardo)"
        ),
        Painting(
            title: "Girl with a Pearl Earring",
            artist: "Johannes Vermeer",
            year: 1665,
            period: .baroque,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/1665_Girl_with_a_Pearl_Earring.jpg/800px-1665_Girl_with_a_Pearl_Earring.jpg",
            description: "Girl with a Pearl Earring is an oil painting by Dutch Golden Age painter Johannes Vermeer. It is a tronie of a girl wearing exotic dress and a large pearl earring. The work is oil on canvas and is 44.5 cm × 39 cm.",
            museum: "Mauritshuis",
            location: "The Hague, Netherlands",
            dimensions: "44.5 cm × 39 cm",
            medium: "Oil on canvas",
            wikiURL: "https://en.wikipedia.org/wiki/Girl_with_a_Pearl_Earring"
        ),
        Painting(
            title: "The Persistence of Memory",
            artist: "Salvador Dalí",
            year: 1931,
            period: .surrealism,
            imageURL: "https://upload.wikimedia.org/wikipedia/en/d/dd/The_Persistence_of_Memory.jpg",
            description: "The Persistence of Memory is a 1931 painting by artist Salvador Dalí and one of the most recognizable works of Surrealism. The well-known surrealist piece introduced the image of the soft melting pocket watch.",
            museum: "Museum of Modern Art",
            location: "New York City, USA",
            dimensions: "24 cm × 33 cm",
            medium: "Oil on canvas",
            wikiURL: "https://en.wikipedia.org/wiki/The_Persistence_of_Memory"
        )
    ]
}
