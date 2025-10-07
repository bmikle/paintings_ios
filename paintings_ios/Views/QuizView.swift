//
//  QuizView.swift
//  paintings_ios
//
//  Created by Michael Bogorad on 07.10.2025.
//

import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: PaintingsViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text("Quiz Mode")
                .font(.largeTitle)
                .fontWeight(.bold)

            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 12) {
                    Image(systemName: "photo.artframe")
                        .font(.system(size: 80))
                        .foregroundStyle(.white.opacity(0.8))

                    Text("Painting Image")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)

            VStack(spacing: 16) {
                ForEach(1...4, id: \.self) { index in
                    Button(action: {}) {
                        Text("Answer Option \(index)")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }
}
