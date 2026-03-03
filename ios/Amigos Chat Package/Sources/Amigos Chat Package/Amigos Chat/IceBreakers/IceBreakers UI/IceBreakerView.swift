//
//  IceBreaker.swift
//  Amigos Chat Package
//
//  Created by Jarret on 05/02/2026.
//

import SwiftUI

struct IceBreakerView: View {

    @ObservedObject private var viewModel: IceBreakerViewModel

    @Environment(\.dismiss) var dismiss

    public init(viewModel: IceBreakerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                descriptionView
                swiperContent
                buttonView
            }
            .navigationTitle(viewModel.navTitle)
            .toolbarTitleDisplayMode(.inline)
        }
        .foregroundStyle(Color(.greyDark))
        .padding(16)
        .background(Color(.chatBackground))
    }

    private var descriptionView: some View {
        Text(viewModel.description)
            .font(.body)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var swiperContent: some View {
        TabView(selection: $viewModel.selectedIndex) {
            ForEach(viewModel.messageSuggestions.indices, id: \.self) { index in
                let message = viewModel.messageSuggestions[index]
                Text(message)
                    .font(.caption1)
                    .chatBubble(
                        isSentByCurrentUser: true,
                        messagePosition: .top,
                        forceLeftToRight: false,
                        contentInsets: .defaultMessageEdgeInsets
                    )
                    .frame(maxWidth: .messageWidth)
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .tint(Color(.purple))
        .background(Color(.greyLight))
        .foregroundStyle(Color(.white))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var buttonView: some View {
        AmiButton(viewModel.buttonTitle) {
            if let message = viewModel.selectedMessage {
                viewModel.select(message)
                dismiss()
            }
        }
        .frame(height: 50)
        .disabled(viewModel.selectedMessage == nil)
    }
}

#Preview {
    let inFiveDays = Calendar.current.date(byAdding: .day, value: 5, to: Date.now)

     IceBreakerView(
        viewModel: IceBreakerViewModel(
            activityDate: inFiveDays,
            messageSuggestionsResolver: IceBreakerHostSuggestionResolver()
        )
    )
}

