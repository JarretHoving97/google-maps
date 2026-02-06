//
//  ReadReceiptsView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 16/01/2026.
//

import SwiftUI

struct ReadReceiptsView: View {

    @StateObject var viewModel: ReadReceiptsViewModel

    let router: Router?

    init(viewModel: ReadReceiptsViewModel, router: Router? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.router = router
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .animation(.easeIn, value: viewModel.receipts)
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.navigationTitleLabel)
    }

    @ViewBuilder
    private var content: some View {
        if !viewModel.isLoading && viewModel.receipts.isEmpty {
            noReceiptsContentView
        } else {
            readReceiptsScrollableView
        }
    }

    private var readReceiptsScrollableView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                VStack {
                    readByLabelView
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.receipts.indices, id: \.self) { index in
                            let receipt = viewModel.receipts[index]
                            ReadReceiptCell(viewModel: receipt)
                                .onTapGesture {
                                    router?.push(.client(.profileRoute(id: receipt.id)))
                                }
                                .onAppear {
                                    viewModel.loadReceipts(for: index)
                                }
                        }

                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color(.chatBackground))
                        }
                    }
                }
                .padding(16)
            }
        }
    }

    private var noReceiptsContentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            readByLabelView
            VStack {
                Spacer()
                Text(viewModel.noReadReceiptsLabel)
                    .font(.body)
                    .foregroundStyle(Color(.grey))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
        }
        .padding(16)
    }

    private var readByLabelView: some View {
        Text(viewModel.readByLabel)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.subheadline)
    }
}
