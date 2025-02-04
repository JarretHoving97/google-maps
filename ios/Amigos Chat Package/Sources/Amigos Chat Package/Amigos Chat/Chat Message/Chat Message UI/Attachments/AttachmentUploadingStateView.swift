//
//  AttachmentUploadingStateView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/01/2025.
//

import SwiftUI

struct AttachmentUploadingStateView: View {

    var uploadingState: UploadingState?

    var body: some View {

        Group {
            if let uploadingState {
                switch uploadingState.state {

                case .uploading(let progress):
                    BottomRightView {
                        HStack(spacing: 4) {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: .white)
                                )
                                .scaleEffect(0.7)

                            Text(progressDisplay(for: progress))
                                .foregroundStyle(.white)
                                .font(.subheadline)

                        }
                        .padding(.all, 4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.all, 8)
                    }
                case .uploadingFailed:

                    BottomRightView {

                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .renderingMode(.template)
                                .foregroundStyle(.white)

                        }
                        .padding(.all, 6)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.all, 8)
                    }

                default:
                    EmptyView()
                }
            }
        }
    }

    private func progressDisplay(for progress: CGFloat) -> String {
        let value = Int(progress * 100)
        return "\(value)%"
    }
}

/// View container that allows injecting another view in its bottom right corner.
private struct BottomRightView<Content: View>: View {
    var content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                content()
            }
        }
    }
}

#Preview {
    AttachmentUploadingStateView(
        uploadingState: .some(
            UploadingState(
                localFileURL: URL(string: "https://google.nl")!,
                state: .uploaded
            )
        )
    )
}

