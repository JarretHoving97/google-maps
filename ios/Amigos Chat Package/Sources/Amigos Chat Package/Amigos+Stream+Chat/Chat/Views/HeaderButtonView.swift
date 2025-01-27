//  HeaderButtonView.swift
//  App
//
//  Created by Jarret on 18/12/2024.
//

import SwiftUI

struct HeaderButtonView: View {

    var iconSystemName: String = "arrow.backward"
    var leading: Bool = true
    var action: (() -> Void)

    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .frame(width: 28, height: 28, alignment: .center)

                Image(systemName: iconSystemName)
                    .resizable()
                    .scaledToFit()
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 16, height: 16, alignment: .center)
                    .foregroundColor(Color("Purple"))
                    .alignmentGuide(HorizontalAlignment.center, computeValue: { viewDimension in
                        viewDimension[HorizontalAlignment.center]
                    })
            }
        }
        .padding(.all, 6)
        .contentShape(Rectangle())
        .buttonStyle(.plain)
    }
}
