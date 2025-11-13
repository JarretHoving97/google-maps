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

            Text(Localized.ChatChannel.communityAdminOnlyNotice)
                .font(.caption2)
                .foregroundStyle(Color(.darkText))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(.noticeHeader))
        .cornerRadius(12)
        .padding(12)
    }

}

#Preview {
    CommunityChatNoticeHeaderView()
}
