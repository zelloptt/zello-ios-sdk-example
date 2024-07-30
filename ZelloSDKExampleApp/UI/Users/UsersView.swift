import SwiftUI
import ZelloSDK

struct UsersView: View {
  @StateObject private var viewModel = UsersViewModel()
  @State private var showSignInDialog = false
  @State private var credentials = ZelloCredentials(username: "", network: "", password: "")
  @State private var showStatusMenu = false
  @State private var showTextInputDialog = false
  @State private var showAlertInputDialog = false
  @State private var userInputText = ""
  @State private var selectedUserForText: ZelloUser?

  var body: some View {
    NavigationView {
      ZStack {
        VStack {
          ScrollView {
            LazyVStack {
              ForEach(viewModel.users, id: \.name) { user in
                HStack {
                  Details(viewModel: viewModel, user: user)
                  Spacer()
                  ActionsButton(viewModel: viewModel,
                                user: user,
                                isMuted: user.isMuted,
                                showTextInputDialog: $showTextInputDialog,
                                showAlertInputDialog: $showAlertInputDialog,
                                userInputText: $userInputText,
                                selectedUserForText: $selectedUserForText)
                  Spacer()
                  TalkButton(viewModel: viewModel, user: user)
                }
                .background(UserStatusColor.color(for: user.status))
                .cornerRadius(5)
              }
              .cornerRadius(5)
              .padding(.horizontal, 12)
              .padding(.vertical, 2)
            }
          }
          StatusMessageView(statusMessage: viewModel.statusMessage)
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

        if showTextInputDialog, let selectedUser = selectedUserForText {
          let contact = ZelloContact.zelloUser(selectedUser)

          InputDialog(
            isVisible: $showTextInputDialog,
            text: $userInputText,
            action: .text,
            contact: contact,
            onSend: {
              viewModel.sendText(user: selectedUser, message: userInputText)
            }
          )
        }

        if showAlertInputDialog, let selectedUser = selectedUserForText {
          let contact = ZelloContact.zelloUser(selectedUser)

          InputDialog(
            isVisible: $showAlertInputDialog,
            text: $userInputText,
            action: .alert,
            contact: contact,
            onSend: {
              viewModel.sendAlert(user: selectedUser, message: userInputText)
            }
          )
        }

        if viewModel.showHistoryPopup, let messages = viewModel.history?.messages {
          HistoryPopupView(isVisible: $viewModel.showHistoryPopup, messages: messages)
        }
      }
      .navigationTitle("Users")
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
    @ObservedObject var viewModel: UsersViewModel
    let user: ZelloUser

    var body: some View {
      let isSelectedContact = (viewModel.selectedContact == .zelloUser(user))
      let displayText = user.displayName != user.name && !user.displayName.isEmpty ? "\(user.displayName) (\(user.name))" : user.name
      Text(displayText)
        .padding(.horizontal, 8)
        .bold(isSelectedContact)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
          viewModel.setSelectedContact(user: user)
        }
    }
  }

  struct UserStatusColor {
    static func color(for status: ZelloUser.UserStatus) -> Color {
      switch status {
      case .offline:
        return .gray.opacity(0.8)
      case .standby:
        return .gray.opacity(0.2)
      case .available:
        return .green.opacity(0.2)
      case .busy:
        return .orange.opacity(0.2)
      @unknown default:
        return .clear
      }
    }
  }

  struct TalkButton: View {
    @ObservedObject var viewModel: UsersViewModel
    let user: ZelloUser

    var body: some View {
      let incomingVoiceMessageViewState = viewModel.incomingVoiceMessageViewState
      let outgoingVoiceMessageViewState = viewModel.outgoingVoiceMessageViewState
      let isSameOutgoingContact = outgoingVoiceMessageViewState?.contact == .zelloUser(user)
      let isSending = isSameOutgoingContact && outgoingVoiceMessageViewState?.state == .sending
      let isReceiving = incomingVoiceMessageViewState?.contact == .zelloUser(user)
      let isConnecting = isSameOutgoingContact && outgoingVoiceMessageViewState?.state == .connecting
      ListItemTalkButton(isSending: isSending, isReceiving: isReceiving, isConnecting: isConnecting, isEnabled: true) {
        viewModel.startSendingMessage(user: user)
      } onUp: {
        viewModel.stopSendingMessage()
      }
    }
  }

  struct ActionsButton: View {
    @ObservedObject var viewModel: UsersViewModel
    let user: ZelloUser
    let isMuted: Bool
    @Binding var showTextInputDialog: Bool
    @Binding var showAlertInputDialog: Bool
    @Binding var userInputText: String
    @Binding var selectedUserForText: ZelloUser?

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
        Button("Send Image", action: sendImage)
        Button("Send Text", action: {
          selectedUserForText = user
          userInputText = ""
          showTextInputDialog = true
        })
        Button("Send Alert", action: {
          selectedUserForText = user
          userInputText = ""
          showAlertInputDialog = true
        })
        Button("Send Location", action: sendLocation)
        Button(isMuted ? "Unmute" : "Mute", action: toggleMute)
        Button("Show History", action: showHistory)
      }
    }

    private func sendImage() {
      if let image = UIImage(named: "TeamHonda") {
        viewModel.sendImage(user: user, image: image)
      }
    }

    private func sendLocation() {
      viewModel.sendLocationTo(user: user)
    }

    private func toggleMute() {
      viewModel.toggleMute(user: user)
    }

    private func showHistory() {
      viewModel.getHistory(user: user)
    }
  }
}

#Preview {
  UsersView()
}