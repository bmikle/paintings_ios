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
        List {
            // First section: Learn all periods
            Section {
                NavigationLink(destination: QuizLessonListView(viewModel: viewModel, lessonType: .allPeriods)) {
                    HStack(spacing: 16) {
                        ZStack {
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            Image(systemName: "calendar.badge.clock")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Art Periods")
                                .font(.headline)

                            Text("Learn to distinguish art periods")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("General")
            }

            // Individual period lessons
            Section {
                ForEach(ArtPeriod.allCases, id: \.self) { period in
                    let paintings = viewModel.paintings.filter { $0.period == period }
                    if !paintings.isEmpty {
                        NavigationLink(destination: QuizLessonListView(viewModel: viewModel, lessonType: .specificPeriod(period))) {
                            HStack(spacing: 16) {
                                ZStack {
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.7), Color.red.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )

                                    Image(systemName: "paintbrush.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(period.displayName)
                                        .font(.headline)

                                    Text("\(paintings.count) painting\(paintings.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            } header: {
                Text("Learn by Period")
            }
        }
        .navigationTitle("Quiz")
    }
}
