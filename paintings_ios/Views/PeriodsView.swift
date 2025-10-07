//
//  PeriodsView.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 07.10.2025.
//

import SwiftUI

struct PeriodsView: View {
    @ObservedObject var viewModel: PaintingsViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var imageSize: CGFloat {
        horizontalSizeClass == .regular ? 100 : 80
    }

    func paintingsForPeriod(_ period: ArtPeriod) -> [Painting] {
        viewModel.paintings.filter { $0.period == period }
    }

    func mostFamousPainting(for period: ArtPeriod) -> Painting? {
        paintingsForPeriod(period).first
    }

    var body: some View {
        List {
            ForEach(ArtPeriod.allCases, id: \.self) { period in
                let paintings = paintingsForPeriod(period)
                if !paintings.isEmpty {
                    NavigationLink(destination: PeriodDetailView(period: period, viewModel: viewModel)) {
                        HStack(alignment: .center, spacing: 12) {
                            // Painting preview
                            if let painting = mostFamousPainting(for: period) {
                                if let url = Bundle.main.url(forResource: painting.imageName, withExtension: "jpg"),
                                   let imageData = try? Data(contentsOf: url),
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: imageSize, height: imageSize)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    // Placeholder
                                    ZStack {
                                        LinearGradient(
                                            colors: [Color.orange.opacity(0.4), Color.red.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )

                                        Image(systemName: "photo.artframe")
                                            .font(.title)
                                            .foregroundStyle(.white.opacity(0.8))
                                    }
                                    .frame(width: imageSize, height: imageSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(period.displayName)
                                    .font(.headline)

                                Text("\(paintings.count) painting\(paintings.count == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                if let painting = mostFamousPainting(for: period) {
                                    Text(painting.title)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Art Periods")
    }
}

struct PeriodDetailView: View {
    let period: ArtPeriod
    @ObservedObject var viewModel: PaintingsViewModel

    var paintings: [Painting] {
        viewModel.paintings.filter { $0.period == period }
    }

    var body: some View {
        List(paintings) { painting in
            PaintingRow(painting: painting)
        }
        .navigationTitle(period.displayName)
    }
}
