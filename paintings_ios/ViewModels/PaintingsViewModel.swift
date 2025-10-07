//
//  PaintingsViewModel.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 06.10.2025.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class PaintingsViewModel: ObservableObject {
    @Published var paintings: [Painting] = []
    @Published var filteredPaintings: [Painting] = []
    @Published var userProgress: UserProgress = UserProgress()
    @Published var searchQuery: String = ""
    @Published var selectedPeriod: ArtPeriod?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let dataService = PaintingsDataService.shared

    init() {
        Task {
            await loadPaintings()
            loadUserProgress()
        }
    }

    func loadPaintings() async {
        isLoading = true
        errorMessage = nil

        do {
            // Always load from bundle
            paintings = try await dataService.loadPaintings()
            filteredPaintings = paintings
        } catch {
            errorMessage = "Failed to load paintings: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func searchPaintings() {
        var results = paintings

        if !searchQuery.isEmpty {
            results = dataService.searchPaintings(results, query: searchQuery)
        }

        if let period = selectedPeriod {
            results = dataService.filterByPeriod(results, period: period)
        }

        filteredPaintings = results
    }

    func toggleFavorite(_ painting: Painting) {
        if userProgress.favoritePaintings.contains(painting.id) {
            userProgress.favoritePaintings.remove(painting.id)
        } else {
            userProgress.favoritePaintings.insert(painting.id)
        }
        saveUserProgress()
    }

    func markAsLearned(_ painting: Painting) {
        userProgress.learnedPaintings.insert(painting.id)
        saveUserProgress()
    }

    func recordView(_ painting: Painting) {
        userProgress.lastViewedDates[painting.id] = Date()
        userProgress.paintingViewCounts[painting.id, default: 0] += 1
        saveUserProgress()
    }

    func isFavorite(_ painting: Painting) -> Bool {
        userProgress.favoritePaintings.contains(painting.id)
    }

    func isLearned(_ painting: Painting) -> Bool {
        userProgress.learnedPaintings.contains(painting.id)
    }

    private func saveUserProgress() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(userProgress)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("userProgress.json")
            try data.write(to: fileURL)
        } catch {
            print("Failed to save user progress: \(error)")
        }
    }

    private func loadUserProgress() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("userProgress.json")
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            userProgress = try decoder.decode(UserProgress.self, from: data)
        } catch {
            // If loading fails, start with fresh progress
            userProgress = UserProgress()
        }
    }
}
