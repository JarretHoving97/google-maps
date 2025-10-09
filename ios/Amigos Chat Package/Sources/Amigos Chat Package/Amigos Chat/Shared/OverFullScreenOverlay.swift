//
//  OverFullScreenOverlay.swift
//  Amigos Chat Package
//
//  Created by Jarret on 29/09/2025.
//

import SwiftUI

struct OverFullScreenOverlay<Content: View>: UIViewControllerRepresentable {
    enum Transition {
        case crossDissolve
        case none
    }

    @Binding var isPresented: Bool
    var transition: Transition = .crossDissolve
    let content: () -> Content

    final class Coordinator {
        var hosting: UIHostingController<AnyView>?
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            if context.coordinator.hosting == nil {
                let hosting = UIHostingController(rootView: AnyView(content().ignoresSafeArea()))
                hosting.view.backgroundColor = .clear
                hosting.modalPresentationStyle = .overFullScreen
                switch transition {
                case .crossDissolve:
                    hosting.modalTransitionStyle = .crossDissolve
                case .none:
                    hosting.modalTransitionStyle = .coverVertical // ignored for overFullScreen if not animated
                }
                uiViewController.present(hosting, animated: true)
                context.coordinator.hosting = hosting
            } else {
                context.coordinator.hosting?.rootView = AnyView(content().ignoresSafeArea())
            }
        } else {
            if let hosting = context.coordinator.hosting {
                hosting.dismiss(animated: true) {
                    context.coordinator.hosting = nil
                }
            }
        }
    }
}

extension View {

    func overlayPresenter<Content: View>(
        isPresented: Binding<Bool>,
        transition: OverFullScreenOverlay<Content>.Transition = .crossDissolve,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        background(
            OverFullScreenOverlay(isPresented: isPresented, transition: transition, content: content)
        )
    }

    @ViewBuilder
    func applyIfAvailablePresentationBackgroundClear() -> some View {
        #if swift(>=5.9)
        if #available(iOS 16.4, *) {
            self.presentationBackground(.clear)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
