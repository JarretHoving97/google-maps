//
//  LocalCreatePollView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/09/2025.
//

import SwiftUI
import StreamChatSwiftUI
import StreamChat
import Combine

public struct CustomCreatePollView: View {

    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    private let maxAmountOfOptions: Int = 10

    @StateObject var viewModel: LocalCreatePollViewModel

    @Environment(\.presentationMode) var presentationMode

    @Environment(\.editMode) var editMode

    @State private var listId = UUID()

    public init(chatController: ChatChannelController, messageController: ChatMessageController?) {
        _viewModel = StateObject(
            wrappedValue: LocalCreatePollViewModel(
                chatController: chatController,
                messageController: messageController
            )
        )
    }

    public var body: some View {
        NavigationView {
            List {
                VStack(alignment: .leading, spacing: 8) {
                    Text(tr("composer.polls.question"))
                        .modifier(ListRowModifier())
                        .padding(.bottom, 4)
                    TextField(tr("composer.polls.askQuestion"), text: $viewModel.question)
                        .modifier(CreatePollItemModifier())
                }
                .modifier(ListRowModifier())

                Text(tr("composer.polls.options"))
                    .modifier(ListRowModifier())
                    .padding(.bottom, -16)

                ForEach(viewModel.options.indices, id: \.self) { index in
                    let disableMove = index == viewModel.options.count - 1 && viewModel.options[index].isEmpty

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            if viewModel.showsOptionError(for: index) {
                                Text(tr("composer.polls.duplicate-option"))
                                    .foregroundColor(Color(colors.alert))
                                    .font(fonts.caption1)
                                    .transition(.opacity)
                            }
                            TextField(tr("composer.polls.add-option"), text: Binding(
                                get: { viewModel.options[index] },
                                set: { newValue in
                                    viewModel.options[index] = newValue
                                    // Check if the current text field is the last one
                                    if index == viewModel.options.count - 1 && viewModel.options.count < maxAmountOfOptions,
                                       !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        // Add a new text field
                                        withAnimation {
                                            viewModel.options.append("")
                                        }
                                    }
                                }
                            ))
                        }

                        if !disableMove {
                            Spacer()

                            Image(systemName: "equal")
                                .foregroundColor(Color(colors.textLowEmphasis))
                        }
                    }
                    .padding(.vertical, viewModel.showsOptionError(for: index) ? -8 : 0)
                    .modifier(CreatePollItemModifier())
                    .moveDisabled(disableMove)
                    .animation(.easeIn, value: viewModel.optionsErrorIndices)
                }
                .onMove(perform: move)
                .onDelete { indices in
                    // Allow deletion of any text field
                    viewModel.options.remove(atOffsets: indices)
                }
                .modifier(ListRowModifier())

                if viewModel.multipleAnswersShown {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(tr("composer.polls.multiple-answers"), isOn: $viewModel.multipleAnswers)
                    }
                    .modifier(CreatePollItemModifier())
                    .padding(.top, 16)
                }

                if viewModel.anonymousPollShown {
                    Toggle(tr("composer.polls.anonymous-poll"), isOn: $viewModel.anonymousPoll)
                        .modifier(CreatePollItemModifier())
                }

                if viewModel.suggestAnOptionShown {
                    Toggle(tr("composer.polls.suggest-option"), isOn: $viewModel.suggestAnOption)
                        .modifier(CreatePollItemModifier())
                }

                if viewModel.addCommentsShown {
                    Toggle(tr("composer.polls.add-comment"), isOn: $viewModel.allowComments)
                        .modifier(CreatePollItemModifier())
                }

                Spacer()
                    .modifier(ListRowModifier())
            }
            .task {
                setupCustomLimitations()
            }
            .background(Color(colors.background).ignoresSafeArea())
            .listStyle(.plain)
            .id(listId)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if viewModel.canShowDiscardConfirmation {
                            viewModel.discardConfirmationShown = true
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .customizable()
                            .frame(width: 16, height: 16)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(.purple))
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(tr("composer.polls.create-poll"))
                        .bold()
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.createPoll {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(colors.tintColor)
                    }
                    .disabled(!viewModel.canCreatePoll)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .actionSheet(isPresented: $viewModel.discardConfirmationShown) {
                ActionSheet(
                    title: Text(tr("composer.polls.action-sheet-discard-title")),
                    buttons: [
                        .destructive(Text(tr("alert.actions.discard-changes"))) {
                            presentationMode.wrappedValue.dismiss()
                        },
                        .cancel(Text(tr("alert.actions.keep-editing")))
                    ]
                )
            }
            .alert(isPresented: $viewModel.errorShown) {
                Alert.defaultErrorAlert
            }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        viewModel.options.move(fromOffsets: source, toOffset: destination)
        listId = UUID()
    }

    private func setupCustomLimitations() {
        viewModel.maxVotes = maxAmountOfOptions.description
    }
}

struct CreatePollItemModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .modifier(ListRowModifier())
            .padding()
            .withPollsBackground()
            .padding(.vertical, -4)
    }
}

struct ListRowModifier: ViewModifier {

    @Injected(\.colors) var colors

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listRowSeparator(.hidden)
                .listRowBackground(Color(colors.background))
        } else {
            content
        }
    }
}

private extension VerticalAlignment {
    private struct TextFieldToggleAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    /// Alignment for a text field with extra text and a toggle.
    static let textFieldToggle = VerticalAlignment(
        TextFieldToggleAlignment.self
    )
}

// MARK: ViewModel

class LocalCreatePollViewModel: ObservableObject {

    @Injected(\.utils) var utils

    @Published var question = ""

    @Published var options: [String] = [""]
    @Published var optionsErrorIndices = Set<Int>()

    @Published var suggestAnOption: Bool

    @Published var anonymousPoll: Bool

    @Published var multipleAnswers: Bool

    @Published var maxVotesEnabled: Bool

    @Published var maxVotes: String = ""
    @Published var showsMaxVotesError = false

    @Published var allowComments: Bool

    @Published var discardConfirmationShown = false

    @Published var errorShown = false

    let chatController: ChatChannelController
    var messageController: ChatMessageController?

    private var cancellables = [AnyCancellable]()

    var pollsConfig: PollsConfig {
        utils.pollsConfig
    }

    var multipleAnswersShown: Bool {
        utils.pollsConfig.multipleAnswers.configurable
    }

    var anonymousPollShown: Bool {
        utils.pollsConfig.anonymousPoll.configurable
    }

    var suggestAnOptionShown: Bool {
        utils.pollsConfig.suggestAnOption.configurable
    }

    var addCommentsShown: Bool {
        utils.pollsConfig.addComments.configurable
    }

    var maxVotesShown: Bool {
        utils.pollsConfig.maxVotesPerPerson.configurable
    }

    init(chatController: ChatChannelController, messageController: ChatMessageController?) {
        let pollsConfig = InjectedValues[\.utils].pollsConfig
        self.chatController = chatController
        self.messageController = messageController

        suggestAnOption = pollsConfig.suggestAnOption.defaultValue
        anonymousPoll = pollsConfig.anonymousPoll.defaultValue
        multipleAnswers = pollsConfig.multipleAnswers.defaultValue
        allowComments = pollsConfig.addComments.defaultValue
        maxVotesEnabled = pollsConfig.maxVotesPerPerson.defaultValue

        $maxVotes
            .map { text in
                guard !text.isEmpty else { return false }
                let intValue = Int(text) ?? 0
                return intValue < 1 || intValue > 10
            }
            .combineLatest($maxVotesEnabled)
            .map { $0 && $1 }
            .removeDuplicates()
            .assignWeakly(to: \.showsMaxVotesError, on: self)
            .store(in: &cancellables)
        $options
            .map { options in
                var errorIndices = Set<Int>()
                var existing = Set<String>(minimumCapacity: options.count)
                for (index, option) in options.enumerated() {
                    let validated = option.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if existing.contains(validated), !validated.isEmpty {
                        errorIndices.insert(index)
                    }
                    existing.insert(validated)
                }
                return errorIndices
            }
            .removeDuplicates()
            .assignWeakly(to: \.optionsErrorIndices, on: self)
            .store(in: &cancellables)
    }

    func createPoll(completion: @escaping () -> Void) {
        let pollOptions = options
            .map(\.trimmed)
            .filter { !$0.isEmpty }
            .map { PollOption(text: $0) }
        let maxVotesAllowed = multipleAnswers ? Int(maxVotes) : nil
        chatController.createPoll(
            name: question.trimmed,
            allowAnswers: allowComments,
            allowUserSuggestedOptions: suggestAnOption,
            enforceUniqueVote: !multipleAnswers,
            maxVotesAllowed: maxVotesAllowed,
            votingVisibility: anonymousPoll ? .anonymous : .public,
            options: pollOptions
        ) { [weak self] result in
            switch result {
            case let .success(messageId):
                log.debug("Created poll in message with id \(messageId)")
                completion()
            case let .failure(error):
                log.error("Error creating a poll: \(error.localizedDescription)")
                self?.errorShown = true
            }
        }
    }

    var canCreatePoll: Bool {
        guard !question.trimmed.isEmpty else { return false }
        guard optionsErrorIndices.isEmpty else { return false }
        guard !showsMaxVotesError else { return false }
        guard options.contains(where: { !$0.trimmed.isEmpty }) else { return false }
        return true
    }

    var canShowDiscardConfirmation: Bool {
        guard question.trimmed.isEmpty else { return true }
        return options.contains(where: { !$0.trimmed.isEmpty })
    }

    func showsOptionError(for index: Int) -> Bool {
        optionsErrorIndices.contains(index)
    }
}



extension String {
    var trimmed: Self {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
