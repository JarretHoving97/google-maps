import Photos
import StreamChat
import SwiftUI
import StreamChatSwiftUI

/// View for the attachment picker.
public struct CustomAttachmentPickerView<Factory: ViewFactory>: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

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

    var isDisplayed: Bool
    var height: CGFloat

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
        height: CGFloat
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
    }
    
    func navigateToSuperAmigoWebView() {
        ExtendedStreamPlugin.shared.notifyNavigateToListeners(route: "/super-amigo", dismiss: true)
    }

    public var body: some View {
        VStack(spacing: 0) {
//            if ExtendedStreamPlugin.shared.superEntitlementStatus == SuperEntitlementStatus.Available {
//                HStack(spacing: 8) {
//                    Image("SuperIcon")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 14)
//                    
//                    Text("custom.composer.attachment.super")
//                        .font(.caption)
//                }
//                .padding(.top, 8)
//                .onTapGesture(perform: navigateToSuperAmigoWebView)
//            } else {
                VStack(spacing: 0) {
                    viewFactory.makeAttachmentSourcePickerView(
                        selected: selectedPickerState,
                        onPickerStateChange: onPickerStateChange
                    )
                    
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
                    } else if selectedPickerState == .custom {
                        viewFactory.makeCustomAttachmentView(
                            addedCustomAttachments: addedCustomAttachments,
                            onCustomAttachmentTap: onCustomAttachmentTap
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
//            }
        }
        .frame(height: isDisplayed ? nil : 0)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentPickerView")
    }
}


