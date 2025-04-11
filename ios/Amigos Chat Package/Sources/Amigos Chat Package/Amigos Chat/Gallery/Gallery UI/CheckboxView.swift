//
//  CheckboxView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/02/2025.
//

import SwiftUI

struct CheckboxView: View {

    let checked: Bool

    init(selected: Bool) {
        self.checked = selected
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(checked ? Color("Purple") : Color.white)

            RoundedRectangle(cornerRadius: 4)
                .stroke(checked ? Color("Purple") : Color("Grey Light"), lineWidth: 2)

            if checked {
                Image("Check")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.white)
            }
        }
        .frame(width: 24, height: 24, alignment: .center)
    }
}

#Preview {
    CheckboxView(selected: true)
}
