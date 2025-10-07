//
//  ArtistsView.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 07.10.2025.
//

import SwiftUI

struct ArtistsView: View {
    @ObservedObject var viewModel: PaintingsViewModel

    var uniqueArtists: [String] {
        Array(Set(viewModel.paintings.map { $0.artist })).sorted()
    }

    var body: some View {
        List {
            ForEach(uniqueArtists, id: \.self) { artist in
                NavigationLink(destination: ArtistDetailView(artist: artist, viewModel: viewModel)) {
                    HStack {
                        ZStack {
                            LinearGradient(
                                colors: [Color.green.opacity(0.6), Color.teal.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            Image(systemName: "paintpalette")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(artist)
                                .font(.headline)

                            Text("\(viewModel.paintings.filter { $0.artist == artist }.count) paintings")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Artists")
    }
}

struct ArtistDetailView: View {
    let artist: String
    @ObservedObject var viewModel: PaintingsViewModel

    var paintings: [Painting] {
        viewModel.paintings.filter { $0.artist == artist }
    }

    var body: some View {
        List(paintings) { painting in
            PaintingRow(painting: painting)
        }
        .navigationTitle(artist)
    }
}
