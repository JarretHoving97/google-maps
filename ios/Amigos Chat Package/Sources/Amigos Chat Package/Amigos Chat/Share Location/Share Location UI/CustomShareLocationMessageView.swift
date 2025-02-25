//
//  CustomShareLocationMessageView.swift
//  App
//
//  Created by Jarret Hoving on 26/11/2024.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI
import MapKit

public struct CustomShareLocationMessageView<Factory: ViewFactory>: View {

    @Injected(\.utils) private var utils
    @Binding var scrolledId: String?
    @State private var presentShareSheet: Bool = false

    private let factory: Factory

    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }
    
    public init(for message: ChatMessage, factory: Factory, isFirst: Bool, scrolledId: Binding<String?>) {
        self.factory = factory
        _scrolledId = scrolledId
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {

        }
    }

    private var usersLocationView: some View {
        ZStack {
            Color(uiColor: UIColor(resource: .coolerGray))
            HStack {

                Image(.chevronRight)
            }
            .padding()
        }
        .roundWithBorder()
        .frame(height: 60)
        .padding(4)
    }
}
