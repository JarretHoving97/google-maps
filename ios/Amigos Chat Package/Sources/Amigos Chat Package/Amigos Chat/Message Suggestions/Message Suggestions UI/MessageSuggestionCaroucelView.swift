//
//  MessageSuggestionCaroucel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 02/02/2026.
//

import SwiftUI

struct MessageSuggestionCaroucelView: View {

    @ObservedObject var viewModel: ChatSuggestionsViewModel

    private let animationDuration: TimeInterval = 0.3

    init(viewModel: ChatSuggestionsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(viewModel.suggestions, id: \.self) { text in
                        Button {
                            handleTap(text, value)
                        } label: {
                            HStack(spacing: 4) {
                                Image(.pencilIcon)
                                    .resizable()
                                    .frame(width: 20, height: 20)

                                Text(text)
                                    .font(.caption1)
                            }
                            .withBorderedMessageBubble()
                            .flipHorizontally()
                        }
                        .id(text)
                        .scrollTargetLayout()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .padding(.horizontal, 11)
            }
            .flipHorizontally()
            .scrollTargetBehavior(.viewAligned)
            .task {
                if let last = viewModel.suggestions.last {
                    value.scrollTo(last, anchor: .leading)
                }
            }
        }
        .disabled(viewModel.isScrolling)
        .onAppear {
            viewModel.load()
        }
    }

    func handleTap(_ text: String, _ value: ScrollViewProxy) {
        guard !viewModel.isScrolling else { return }
        viewModel.isScrolling = true

        withAnimation(nil) {
            viewModel.selectSuggestion(text)
        }

        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: animationDuration)) {
                value.scrollTo(text, anchor: .center)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                viewModel.isScrolling = false
            }
        }
    }
}

private extension View {

    func flipHorizontally() -> some View {
        rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
}

#Preview {
    let templates: [ReminderCategory: [String]] = [
        .fourtyEightHours: [
            "It's almost time — build anticipation",
            "Share what to expect tomorrow"
        ],
        .nineHours: [
            "Quick reminder for later today",
            "Give the group a friendly nudge",
            "Share a brief update before you meet"
        ],
        .threeHours: [
            "Final checklist before you meet",
            "Share a short summary and details"
        ]
    ]

    let date = Date.now
    let fiveDaysFromNow = Calendar.current.date(byAdding: .day, value: 2, to: date)!

    MessageSuggestionCaroucelView(viewModel: ChatSuggestionsViewModel(
        activityDate: fiveDaysFromNow,
        resolver: MessageSuggestionResolver(templates: templates)
    ))

}
