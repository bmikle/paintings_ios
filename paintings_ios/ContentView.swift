//
//  ContentView.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 06.10.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PaintingsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading paintings...")
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List(viewModel.filteredPaintings) { painting in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(painting.title)
                                .font(.headline)
                            Text(painting.artist)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text("\(painting.year)")
                                    .font(.caption)
                                Text("•")
                                    .font(.caption)
                                Text(painting.period.rawValue)
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Famous Paintings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(viewModel.paintings.count) paintings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
