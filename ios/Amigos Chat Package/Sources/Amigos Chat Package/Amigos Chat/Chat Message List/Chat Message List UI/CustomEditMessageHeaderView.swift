//
//  CustomEditMessageHeaderView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 12/11/2025.
//

import SwiftUI

struct CustomEditMessageHeaderView: View {

    @Binding var editedMessage: Message?

    var body: some View {

        VStack {
            Spacer()

            HStack(alignment: .bottom, spacing: 2) {
                Group {
                    Image(systemName: "pencil")
                        .padding(.bottom, 2)
                    Text(tr("composer.title.edit"))
                }
                .foregroundStyle(Color(.grey))
                .font(.caption2)

                Spacer()

                Button {
                    editedMessage = nil
                } label: {
                    discardButton
                }
                .frame(alignment: .bottom)
            }
            .padding(.leading, 46)
            .padding(.trailing, 58)
            .frame(height: 20)
        }
        .frame(height: 30)
        .padding(.bottom, -10)
    }

    private var discardButton: some View {
        ZStack {
            Image(systemName: "xmark.circle.fill")
                .renderingMode(.template)
                .foregroundColor(Color(.red))
                .frame(width: 20, height: 20, alignment: .bottom)
        }
    }
}

#Preview {
    CustomEditMessageHeaderView(
        editedMessage: .constant(Message(message: "Hello"))
    )
}
