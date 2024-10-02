import StreamChatSwiftUI
import SwiftUI
import StreamChat

/// View displaying the search results in the channel list.
public struct CustomSearchResultsView<Factory: ViewFactory>: View {

    @Injected(\.colors) private var colors

    var factory: Factory
    @Binding var selectedChannel: ChannelSelectionInfo?
    var searchResults: [ChannelSelectionInfo]
    var loadingSearchResults: Bool
    var onlineIndicatorShown: (ChatChannel) -> Bool
    var channelNaming: (ChatChannel) -> String
    var imageLoader: (ChatChannel) -> UIImage
    var onSearchResultTap: (ChannelSelectionInfo) -> Void
    var onItemAppear: (Int) -> Void
    
    public init(
        factory: Factory,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        searchResults: [ChannelSelectionInfo],
        loadingSearchResults: Bool,
        onlineIndicatorShown: @escaping (ChatChannel) -> Bool,
        channelNaming: @escaping (ChatChannel) -> String,
        imageLoader: @escaping (ChatChannel) -> UIImage,
        onSearchResultTap: @escaping (ChannelSelectionInfo) -> Void,
        onItemAppear: @escaping (Int) -> Void
    ) {
        self.factory = factory
        _selectedChannel = selectedChannel
        self.searchResults = searchResults
        self.loadingSearchResults = loadingSearchResults
        self.onlineIndicatorShown = onlineIndicatorShown
        self.channelNaming = channelNaming
        self.imageLoader = imageLoader
        self.onSearchResultTap = onSearchResultTap
        self.onItemAppear = onItemAppear
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(searchResults) { searchResult in
                        CustomSearchResultView(
                            factory: factory,
                            selectedChannel: $selectedChannel,
                            searchResult: searchResult,
                            onlineIndicatorShown: onlineIndicatorShown(searchResult.channel),
                            channelName: channelNaming(searchResult.channel),
                            avatar: imageLoader(searchResult.channel),
                            onSearchResultTap: onSearchResultTap,
                            channelDestination: factory.makeChannelDestination()
                        )
                        .onAppear {
                            if let index = searchResults.firstIndex(where: { result in
                                result.id == searchResult.id
                            }) {
                                onItemAppear(index)
                            }
                        }
                    }
                }
            }
        }
        .overlay(
            loadingSearchResults ? ProgressView() : nil
        )
        .background(Color.white)
    }
}

/// View for one search result item with navigation support.
struct CustomSearchResultView<Factory: ViewFactory>: View {

    var factory: Factory
    @Binding var selectedChannel: ChannelSelectionInfo?
    var searchResult: ChannelSelectionInfo
    var onlineIndicatorShown: Bool
    var channelName: String
    var avatar: UIImage
    var onSearchResultTap: (ChannelSelectionInfo) -> Void
    var channelDestination: (ChannelSelectionInfo) -> Factory.ChannelDestination

    var body: some View {
        ZStack {
            factory.makeChannelListSearchResultItem(
                searchResult: searchResult,
                onlineIndicatorShown: onlineIndicatorShown,
                channelName: channelName,
                avatar: avatar,
                onSearchResultTap: onSearchResultTap,
                channelDestination: channelDestination
            )

            NavigationLink(
                tag: searchResult,
                selection: $selectedChannel
            ) {
                LazyView(channelDestination(searchResult))
            } label: {
                EmptyView()
            }
        }
    }
}
