//
//  PaintingRow.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 07.10.2025.
//

import SwiftUI

struct PaintingRow: View {
    let painting: Painting
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var imageSize: CGFloat {
        horizontalSizeClass == .regular ? 100 : 80
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let url = Bundle.main.url(forResource: painting.imageName, withExtension: "jpg"),
               let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // Placeholder for missing images
                ZStack {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(spacing: 4) {
                        Image(systemName: "photo.artframe")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.8))

                        Text(painting.period.displayName)
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(4)
                }
                .frame(width: imageSize, height: imageSize)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

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
                    Text(painting.period.displayName)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
