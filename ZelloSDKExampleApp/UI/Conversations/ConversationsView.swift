import SwiftUI
import ZelloSDK

struct Conversation: Identifiable {
  let id = UUID()
  let title: String
}

struct ConversationsView: View {
  @StateObject private var viewModel = ConversationsViewModel()
  @State private var showSignInDialog = false
  @State private var credentials = ZelloCredentials(username: "", network: "", password: "")
  @State private var showStatusMenu = false
  @State private var showTextInputDialog = false
  @State private var showAlertInputDialog = false
  @State private var conversationInputText = ""
  @State private var selectedConversation: ZelloGroupConversation?
  @State private var selectedLevel: ZelloAlertMessage.ChannelLevel? = .connected
  @State private var showRenameDialog = false
  @State private var renameInputText = ""
  @State private var showCreateConversationDialog = false
  @State private var showAddUserSelectionView = false
  @State private var selectedUsers = [ZelloUser]()
  @State private var addUsers = [ZelloUser]()

  var body: some View {
    NavigationView {
      ZStack {
        VStack {
          ScrollView {
            LazyVStack {
              ForEach(viewModel.groupConversations, id: \.name) { conversation in
                let isConnecting = viewModel.connectionViewState.connectionState == .connecting

                 HStack {
                  Details(viewModel: viewModel, conversation: conversation)
                  ConnectionToggle(viewModel: viewModel, conversation: conversation)
                   Spacer()
                   ActionsButton(viewModel: viewModel,
                                 conversation: conversation,
                                 isMuted: conversation.isMuted,
                                 showTextInputDialog: $showTextInputDialog,
                                 showAlertInputDialog: $showAlertInputDialog,
                                 conversationInputText: $conversationInputText,
                                 selectedConversation: $selectedConversation,
                                 showRenameDialog: $showRenameDialog,
                                 renameInputText: $renameInputText,
                                 showAddUserSelectionView: $showAddUserSelectionView,
                                 selectedUsers: $selectedUsers,
                                 addUsers: $addUsers
                   )
                   Spacer()
                   TalkButton(viewModel: viewModel, conversation: conversation)
                 }
                 .background(isConnecting ? Color.yellow.opacity(0.5) : Color.clear)
                 .cornerRadius(5)
                 .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                  viewModel.setSelectedContact(conversation: conversation)
                }
                .cornerRadius(5)
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
              }
            }
          }
          StatusMessageView(statusMessage: viewModel.statusMessage)
        }

        VStack {
          Spacer()
          HStack {
            Spacer()
            Button(action: {
              showCreateConversationDialog = true
            }) {
              Image(systemName: "plus")
                .font(.system(size: 24))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 4)
            }
            .padding()
          }
        }

        if showSignInDialog {
          SignInPrompt(
            showDialog: $showSignInDialog,
            credentials: $credentials
          ) {
            viewModel.connect(credentials: credentials)
          }
        }

        if viewModel.showImagePopup {
          ImagePopupView(isVisible: $viewModel.showImagePopup,
                         imageMessage: viewModel.incomingImageMessage)
        }

        if viewModel.showTextPopup {
          TextPopupView(isVisible: $viewModel.showTextPopup,
                         textMessage: viewModel.incomingTextMessage)
        }

        if viewModel.showAlertPopup {
          AlertPopupView(isVisible: $viewModel.showAlertPopup,
                         alertMessage: viewModel.incomingAlertMessage)
        }

        if viewModel.showLocationPopup {
          LocationPopupView(isVisible: $viewModel.showLocationPopup,
                         locationMessage: viewModel.incomingLocationMessage)
        }

        if showTextInputDialog, let selectedConversation {
          let contact = ZelloContact.conversation(selectedConversation)

          InputDialog(
            isVisible: $showTextInputDialog,
            text: $conversationInputText,
            action: .text,
            contact: contact,
            conversation: selectedConversation,
            onSend: {
              viewModel.sendText(conversation: selectedConversation, message: conversationInputText)
            }
          )
        }

        if showAlertInputDialog, let selectedConversation = selectedConversation {
          let contact = ZelloContact.conversation(selectedConversation)

          InputDialog(
            isVisible: $showAlertInputDialog,
            text: $conversationInputText,
            selectedLevel: $selectedLevel,
            action: .alert,
            contact: contact,
            conversation: selectedConversation,
            onSend: {
              viewModel.sendAlert(conversation: selectedConversation, message: conversationInputText, level: selectedLevel)
            }
          )
        }

        if viewModel.showHistoryPopup, let messages = viewModel.history?.messages {
          HistoryPopupView(isVisible: $viewModel.showHistoryPopup, messages: messages)
        }

        if showCreateConversationDialog {
          UserSelectionView(
            isVisible: $showCreateConversationDialog,
            selectedUsers: $selectedUsers,
            allUsers: viewModel.users.filter { $0.supportedFeatures.groupConversations },
            title: "Create Conversation",
            onCreate: {
              viewModel.createConversation(users: selectedUsers)
            }
          )
        }

        if showAddUserSelectionView, let selectedConversation {
          UserSelectionView(
            isVisible: $showAddUserSelectionView,
            selectedUsers: $selectedUsers,
            allUsers: addUsers.filter { $0.supportedFeatures.groupConversations },
            title: "Add Users",
            onCreate: {
              viewModel.add(selectedUsers, to: selectedConversation)
            }
          )
        }

        if showRenameDialog, let selectedConversation {
          InputDialog(
            isVisible: $showRenameDialog,
            text: $renameInputText,
            action: .rename,
            contact: ZelloContact.conversation(selectedConversation),
            conversation: selectedConversation,
            onSend: {
              viewModel.rename(selectedConversation, to: renameInputText)
            }
          )
        }
      }
      .navigationTitle("Conversations")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarItems(
        leading: viewModel.isConnected ? AnyView(StatusActionSheet(
          showStatusMenu: $showStatusMenu,
          accountStatus: $viewModel.accountStatus,
          updateAccountStatus: viewModel.setAccountStatus
        )) : AnyView(EmptyView()),
        trailing: ConnectNavBarButton(viewModel: viewModel, onConnectButtonTapped: {
          showSignInDialog = true
        })
      )
    }
  }

  private func updateAccountStatus(_ status: ZelloAccountStatus) {
    viewModel.setAccountStatus(status: status)
  }

  struct Details: View {
    @ObservedObject var viewModel: ConversationsViewModel
    let conversation: ZelloGroupConversation

    var body: some View {
      VStack {
        let isSelectedContact = viewModel.selectedContact == .conversation(conversation)
        Text(conversation.displayName)
          .bold(isSelectedContact)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(conversation.status == .connected ? "Connected" : conversation.status == .connecting ? "Connecting" : "Disconnected")
          .bold(isSelectedContact)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text("\(conversation.onlineUsers.count) users connected")
          .bold(isSelectedContact)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }

  struct ConnectionToggle: View {
    @ObservedObject var viewModel: ConversationsViewModel
    let conversation: ZelloGroupConversation

    var body: some View {
      Toggle("", isOn: .constant(conversation.status == .connected))
        .disabled(conversation.status == .connecting)
        .onTapGesture {
          if conversation.status == .connected {
            viewModel.disconnect(from: conversation)
          } else {
            viewModel.connect(to: conversation)
          }
        }
    }
  }

  struct TalkButton: View {
    @ObservedObject var viewModel: ConversationsViewModel
    let conversation: ZelloGroupConversation

    var body: some View {
      let incomingVoiceMessageViewState = viewModel.incomingVoiceMessageViewState
      let outgoingVoiceMessageViewState = viewModel.outgoingVoiceMessageViewState
      let isSameOutgoingContact = outgoingVoiceMessageViewState?.contact == .conversation(conversation)
      let isSending = isSameOutgoingContact && outgoingVoiceMessageViewState?.state == .sending
      let isReceiving = incomingVoiceMessageViewState?.contact == .conversation(conversation)
      let isConnecting = isSameOutgoingContact && outgoingVoiceMessageViewState?.state == .connecting
      ListItemTalkButton(isSending: isSending, isReceiving: isReceiving, isConnecting: isConnecting, isEnabled: true) {
        viewModel.startSendingMessage(conversation: conversation)
      } onUp: {
        viewModel.stopSendingMessage()
      }
    }
  }

  struct ActionsButton: View {
    @ObservedObject var viewModel: ConversationsViewModel
    let conversation: ZelloGroupConversation
    let isMuted: Bool
    @Binding var showTextInputDialog: Bool
    @Binding var showAlertInputDialog: Bool
    @Binding var conversationInputText: String
    @Binding var selectedConversation: ZelloGroupConversation?
    @Binding var showRenameDialog: Bool
    @Binding var renameInputText: String
    @Binding var showAddUserSelectionView: Bool
    @Binding var selectedUsers: [ZelloUser]
    @Binding var addUsers: [ZelloUser]

    var body: some View {
      Button(action: {}) {
        Image(systemName: "ellipsis").font(.title)
      }
      .cornerRadius(5)
      .padding(.horizontal, 10)
      .padding(.vertical, 14)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color(red: 0.8, green: 0.8, blue: 0.8))
      )
      .buttonStyle(PlainButtonStyle())
      .contentShape(Rectangle())
      .contextMenu {
        if viewModel.settings?.allowsImageMessages == true && conversation.status == .connected {
          Button("Send Image", action: sendImage)
        }
        if viewModel.settings?.allowsTextMessages == true && conversation.status == .connected {
          Button("Send Text", action: {
            selectedConversation = conversation
            conversationInputText = ""
            showTextInputDialog = true
          })
        }

        if viewModel.settings?.allowsAlertMessages == true && conversation.status == .connected {
          Button("Send Alert", action: {
            selectedConversation = conversation
            conversationInputText = ""
            showAlertInputDialog = true
          })
        }
        if viewModel.settings?.allowsLocationMessages == true && conversation.status == .connected {
          Button("Send Location", action: sendLocation)
        }
        Button(isMuted ? "Unmute" : "Mute", action: toggleMute)
        Button("Show History", action: showHistory)
        Button("Leave Conversation", action: leaveConversation)
        Button("Rename Conversation", action: {
          selectedConversation = conversation
          renameInputText = conversation.displayName
          showRenameDialog = true
        })
        Button("Add Users", action: {
          selectedConversation = conversation
          addUsers = viewModel.users.filter { user in
            !conversation.users.contains(where: { $0.name == user.name })
          }
          showAddUserSelectionView = true
        })
      }
    }

    private func sendImage() {
      print("Send Image selected")
      if let image = UIImage(named: "TeamHonda") {
        viewModel.sendImage(conversation: conversation, image: image)
      }
    }

    private func sendLocation() {
      viewModel.sendLocationTo(conversation: conversation)
    }

    private func toggleMute() {
      viewModel.toggleMute(conversation: conversation)
    }

    private func showHistory() {
      viewModel.getHistory(conversation: conversation)
    }

    private func leaveConversation() {
      viewModel.leave(conversation)
    }
  }
}
