//
//  MessageSuggestionFooterViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 11/02/2026.
//

import SwiftUI

struct MessageSuggestionFooterView: View {

    @Binding var showIcebreakersSheet: Bool

    @StateObject var viewModel: MessageSuggestionFooterViewModel

    init(showIcebreakersSheet: Binding<Bool>, viewModel: MessageSuggestionFooterViewModel) {
        _showIcebreakersSheet = showIcebreakersSheet
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        HStack {
            HStack(spacing: -20) {
                if viewModel.showMessageSuggestions {
                    MessageSuggestionCaroucelView(
                        viewModel: viewModel.hostMessageSuggestionsViewModel
                    )
                    .flippedUpsideDown()
                    .zIndex(0)
                } else {
                    Spacer()
                }

                if viewModel.showsIceBreakerButton {
                    IceBreakerButton { showIcebreakersSheet.toggle() }
                        .flippedUpsideDown()
                        .zIndex(1)
                }
            }

            if viewModel.showsIceBreakerButton {
                Spacer(minLength: 28)
            }
        }
        .padding(.horizontal, -18)
    }
}

#Preview {
    MessageSuggestionFooterView(
        showIcebreakersSheet: .constant(true),
        viewModel: MessageSuggestionFooterViewModel(
            hostMessageSuggestionsViewModel: ChatSuggestionsViewModel(
                activityDate: Calendar.current.date(byAdding: .day, value: 2, to: Date.now),
                resolver: HostMessageSuggestionResolver()
            ),
            showMessageSuggestions: true,
            showsIceBreakerButton: true
        )
    )
    .flippedUpsideDown()
}
