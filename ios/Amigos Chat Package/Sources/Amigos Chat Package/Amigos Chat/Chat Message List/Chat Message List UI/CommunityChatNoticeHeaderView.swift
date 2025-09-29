//
//  CommunityNoticeHeaderViwew.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/09/2025.
//

import SwiftUI

struct CommunityChatNoticeHeaderView: View {

    var body: some View {

        HStack(spacing: 10) {
            Image("infoIcon", bundle: .module)
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .tint(Color(.greyDark))

            Text(Localized.ChatChannel.communityShareAdminOnly)
                .font(.caption2)
                .foregroundStyle(Color(.darkText))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.04), radius: 8, x: 0, y: 2)
        .padding(12)
    }

}

#Preview {
    CommunityChatNoticeHeaderView()
}
