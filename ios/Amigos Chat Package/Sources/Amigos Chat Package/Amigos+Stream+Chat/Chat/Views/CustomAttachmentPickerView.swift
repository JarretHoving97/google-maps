import Photos
import StreamChat
import SwiftUI
import StreamChatSwiftUI

public struct CustomAttachmentPickerView<Factory: ViewFactory>: View {
    @EnvironmentObject var viewModel: MessageComposerViewModel

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.chatRouter) private var router

    var viewFactory: Factory
    @Binding var selectedPickerState: AttachmentPickerState
    @Binding var filePickerShown: Bool
    @Binding var cameraPickerShown: Bool
    @Binding var addedFileURLs: [URL]

    var onPickerStateChange: (AttachmentPickerState) -> Void
    var photoLibraryAssets: PHFetchResult<PHAsset>?
    var onAssetTap: (AddedAsset) -> Void
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    var isAssetSelected: (String) -> Bool
    var addedCustomAttachments: [CustomAttachment]
    var cameraImageAdded: (AddedAsset) -> Void
    var askForAssetsAccessPermissions: () -> Void

    /// custom
    @State private var showShareLocaiton: Bool = false

    var isDisplayed: Bool
    var height: CGFloat
    var popupHeight: CGFloat

    public init(
        viewFactory: Factory,
        selectedPickerState: Binding<AttachmentPickerState>,
        filePickerShown: Binding<Bool>,
        cameraPickerShown: Binding<Bool>,
        addedFileURLs: Binding<[URL]>,
        onPickerStateChange: @escaping (AttachmentPickerState) -> Void,
        photoLibraryAssets: PHFetchResult<PHAsset>? = nil,
        onAssetTap: @escaping (AddedAsset) -> Void,
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        isAssetSelected: @escaping (String) -> Bool,
        addedCustomAttachments: [CustomAttachment],
        cameraImageAdded: @escaping (AddedAsset) -> Void,
        askForAssetsAccessPermissions: @escaping () -> Void,
        isDisplayed: Bool,
        height: CGFloat,
        popupHeight: CGFloat
    ) {
        self.viewFactory = viewFactory
        _selectedPickerState = selectedPickerState
        _filePickerShown = filePickerShown
        _cameraPickerShown = cameraPickerShown
        _addedFileURLs = addedFileURLs
        self.onPickerStateChange = onPickerStateChange
        self.photoLibraryAssets = photoLibraryAssets
        self.onAssetTap = onAssetTap
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.isAssetSelected = isAssetSelected
        self.addedCustomAttachments = addedCustomAttachments
        self.cameraImageAdded = cameraImageAdded
        self.askForAssetsAccessPermissions = askForAssetsAccessPermissions
        self.isDisplayed = isDisplayed
        self.height = height
        self.popupHeight = popupHeight
    }

    func navigateToSuperAmigoWebView() {
        router?.push(.client(.superAmigoRoute))
    }

    public var body: some View {
        VStack(spacing: 0) {
            viewFactory.makeAttachmentSourcePickerView(
                selected: selectedPickerState,
                onPickerStateChange: onPickerStateChange
            )
            .environmentObject(viewModel)

            if selectedPickerState == .photos {
                if let assets = photoLibraryAssets {
                    let collection = PHFetchResultCollection(fetchResult: assets)
                    if !collection.isEmpty {
                        viewFactory.makePhotoAttachmentPickerView(
                            assets: collection,
                            onAssetTap: onAssetTap,
                            isAssetSelected: isAssetSelected
                        )
                        .edgesIgnoringSafeArea(.bottom)
                    } else {
                        viewFactory.makeAssetsAccessPermissionView()
                    }
                } else {
                    ProgressView()
                }

            } else if selectedPickerState == .files {
                viewFactory.makeFilePickerView(
                    filePickerShown: $filePickerShown,
                    addedFileURLs: $addedFileURLs
                )
            } else if selectedPickerState == .camera {
                viewFactory.makeCameraPickerView(
                    selected: $selectedPickerState,
                    cameraPickerShown: $cameraPickerShown,
                    cameraImageAdded: cameraImageAdded
                )
            } else if selectedPickerState == .polls {
                LocalComposerPollView(
                    channelController: viewModel.channelController,
                    messageController: viewModel.messageController
                ) {
                    selectedPickerState = .photos
                }
            } else if selectedPickerState == .custom, let shareLocationView = CustomUIFactory.shareCurrentLocationView {
                // custom factory
                viewFactory.makeCustomShareLocation(
                    shareLocationView,
                    locationPickerShown: $showShareLocaiton,
                    onDissapear: {
                        selectedPickerState = .photos
                    },
                    onShareLocation: { location in

                        guard let coordinate = location?.coordinate else { return }

                        onCustomAttachmentTap(CustomAttachment(
                            id: UUID().uuidString,
                            content: AnyAttachmentPayload(
                                payload: LocationAttachmentPayload(
                                    lat: coordinate.latitude,
                                    lon: coordinate.longitude
                                )
                            )
                        ))
                    }
                )
            }
        }
        .frame(height: height)
        .background(Color(colors.background1))
        .onChange(of: isDisplayed) { newValue in
            if newValue {
                askForAssetsAccessPermissions()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentPickerView")

        .offset(y: isDisplayed ? 0 : popupHeight)
        .animation(.spring())
    }
}

 struct LocalComposerPollView: View {
    @State private var showsOnAppear = true
    @State private var showsCreatePoll = false

    let channelController: ChatChannelController
    let messageController: ChatMessageController?

    var onCreatePollDissapears: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Button {
                showsCreatePoll = true
            } label: {
                Text(tr("composer.polls.create-poll"))
            }

            Spacer()
        }
        .fullScreenCover(isPresented: $showsCreatePoll) {
            CustomCreatePollView(
                chatController: channelController,
                messageController: messageController
            )
        }
        .onAppear {
            guard showsOnAppear else { return }
            showsOnAppear = false
            showsCreatePoll = true
        }

        .onChange(of: showsCreatePoll) { newValue in
            if newValue == false {
                DispatchQueue.main.async {
                    onCreatePollDissapears()
                }
            }
        }
    }
}
