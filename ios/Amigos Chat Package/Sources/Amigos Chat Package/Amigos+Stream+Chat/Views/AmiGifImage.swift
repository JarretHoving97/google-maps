// swiftlint:disable all
import SwiftUI
import WebKit

struct AmiGifImage: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> some WKWebView {
        let webView = WKWebView()

        print(name)

        let url = Bundle.module.url(forResource: name, withExtension: "gif")!

        let data = try! Data(contentsOf: url)

        webView.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: url.deletingLastPathComponent()
        )

        webView.scrollView.isScrollEnabled = false

        return webView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.reload()
    }
}
