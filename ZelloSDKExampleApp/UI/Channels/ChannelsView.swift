import SwiftUI
import ZelloSDK

struct ChannelsView: View {
  @StateObject private var viewModel = ChannelsViewModel()
  @State private var showSignInDialog = false
  @State private var credentials = ZelloCredentials(username: "", network: "", password: "")
  @State private var showStatusMenu = false
  @State private var showTextInputDialog = false
  @State private var showAlertInputDialog = false
  @State private var channelInputText = ""
  @State private var selectedChannelForText: ZelloChannel?
  @State private var selectedLevel: ZelloAlertMessage.ChannelLevel? = .connected

  var body: some View {
    NavigationView {
      ZStack {
        VStack {
          ScrollView {
            LazyVStack {
              ForEach(viewModel.channels, id: \.name) { channel in
                let isConnecting = viewModel.connectionViewState.connectionState == .connecting

                let showEndCallButton = shouldShowEndCallButton(for: channel)

                HStack {
                  Details(viewModel: viewModel, channel: channel, callStatus: channel.dispatchInfo?.currentCall?.status.rawValue)
                  ConnectionToggle(viewModel: viewModel, channel: channel)
                  Spacer()
                  ActionsButton(viewModel: viewModel,
                                channel: channel,
                                isMuted: channel.isMuted,
                                showEndCallButton: showEndCallButton,
                                showSendLocation: channel.channelOptions.allowLocations && viewModel.settings?.allowsLocationMessages == true && channel.status == .connected,
                                showSendImage: viewModel.settings?.allowsImageMessages == true && channel.status == .connected,
                                showSendAlert: channel.channelOptions.allowAlerts && viewModel.settings?.allowsAlertMessages == true && channel.status == .connected,
                                showSendText: channel.channelOptions.allowTextMessages && viewModel.settings?.allowsTextMessages == true && channel.status == .connected,
                                showTextInputDialog: $showTextInputDialog,
                                showAlertInputDialog: $showAlertInputDialog,
                                channelInputText: $channelInputText,
                                selectedChannelForText: $selectedChannelForText)
                  Spacer()
                  TalkButton(viewModel: viewModel, channel: channel)
                }
                .background(isConnecting ? Color.yellow.opacity(0.5) : Color.clear)
                .cornerRadius(5)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                  viewModel.setSelectedContact(channel: channel)
                }
                .cornerRadius(5)
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
              }
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

        if showTextInputDialog, let selectedChannel = selectedChannelForText {
          let contact = ZelloContact.channel(selectedChannel)

          InputDialog(
            isVisible: $showTextInputDialog,
            text: $channelInputText,
            action: .text,
            contact: contact,
            conversation: nil,
            onSend: {
              viewModel.sendText(channel: selectedChannel, message: channelInputText)
            }
          )
        }

        if showAlertInputDialog, let selectedChannel = selectedChannelForText {
          let contact = ZelloContact.channel(selectedChannel)

          InputDialog(
            isVisible: $showAlertInputDialog,
            text: $channelInputText,
            selectedLevel: $selectedLevel,
            action: .alert,
            contact: contact,
            conversation: nil,
            onSend: {
              viewModel.sendAlert(channel: selectedChannel, message: channelInputText, level: selectedLevel)
            }
          )
        }

        if viewModel.showHistoryPopup, let messages = viewModel.history?.messages {
          HistoryPopupView(isVisible: $viewModel.showHistoryPopup, messages: messages)
        }
      }
      .navigationTitle("Channels")
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

  private func shouldShowEndCallButton(for channel: ZelloChannel) -> Bool {
      guard let dispatchInfo = channel.dispatchInfo,
            let currentCall = dispatchInfo.currentCall else {
        return false
      }
      return currentCall.status == .active &&
             viewModel.settings?.allowsNonDispatchersToEndCalls == true
    }

  private func updateAccountStatus(_ status: ZelloAccountStatus) {
    viewModel.setAccountStatus(status: status)
  }

  struct Details: View {
    @ObservedObject var viewModel: ChannelsViewModel
    let channel: ZelloChannel
    // SwiftUI doesn't know how to properly observe changes in nested structs, so we need to lift this out
    let callStatus: String?

    var body: some View {
      VStack {
        let isSelectedContact = viewModel.selectedContact == .channel(channel)
        Text(channel.name)
          .bold(isSelectedContact)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(channel.status == .connected ? "Connected" : channel.status == .connecting ? "Connecting" : "Disconnected")
          .bold(isSelectedContact)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(channel.usersOnline.description + " users connected")
          .bold(isSelectedContact)
          .frame(maxWidth: .infinity, alignment: .leading)
        if viewModel.outgoingEmergency?.channel == channel {
          Text("ACTIVE OUTGOING EMERGENCY")
            .bold(isSelectedContact)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        if let callStatus {
          Text("Call status: \(callStatus)")
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        if let emergency = viewModel.incomingEmergencies.first(where: { emergency in
          emergency.channel == channel
        }) {
          Text("ACTIVE INCOMING EMERGENCY : " + emergency.channelUser.name)
            .bold(isSelectedContact)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
  }

  struct ConnectionToggle: View {
    @ObservedObject var viewModel: ChannelsViewModel
    let channel: ZelloChannel

    var body: some View {
      Toggle("", isOn: .constant(channel.status == .connected))
        .disabled(channel.status == .connecting)
        .onTapGesture {
          if channel.status == .connected {
            viewModel.disconnect(from: channel)
          } else {
            viewModel.connect(to: channel)
          }
        }
    }
  }

  struct TalkButton: View {
    @ObservedObject var viewModel: ChannelsViewModel
    let channel: ZelloChannel

    var body: some View {
      let incomingVoiceMessageViewState = viewModel.incomingVoiceMessageViewState
      let outgoingVoiceMessageViewState = viewModel.outgoingVoiceMessageViewState
      let isSameOutgoingContact = outgoingVoiceMessageViewState?.contact == .channel(channel)
      let isSending = isSameOutgoingContact && outgoingVoiceMessageViewState?.state == .sending
      let isReceiving = incomingVoiceMessageViewState?.contact == .channel(channel)
      let isConnecting = isSameOutgoingContact && outgoingVoiceMessageViewState?.state == .connecting
      ListItemTalkButton(isSending: isSending, isReceiving: isReceiving, isConnecting: isConnecting, isEnabled: true) {
        viewModel.startSendingMessage(channel: channel)
      } onUp: {
        viewModel.stopSendingMessage()
      }
    }
  }

  struct ActionsButton: View {
    @ObservedObject var viewModel: ChannelsViewModel
    let channel: ZelloChannel
    let isMuted: Bool
    let showEndCallButton: Bool
    let showSendLocation: Bool
    let showSendImage: Bool
    let showSendAlert: Bool
    let showSendText: Bool
    @Binding var showTextInputDialog: Bool
    @Binding var showAlertInputDialog: Bool
    @Binding var channelInputText: String
    @Binding var selectedChannelForText: ZelloChannel?

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
        if showSendImage {
          Button("Send Image", action: sendImage)
        }
        if showSendText {
          Button("Send Text", action: {
            selectedChannelForText = channel
            channelInputText = ""
            showTextInputDialog = true
          })
        }
        if showSendAlert {
          Button("Send Alert", action: {
            selectedChannelForText = channel
            channelInputText = ""
            showAlertInputDialog = true
          })
        }
        if showSendLocation {
          Button("Send Location", action: sendLocation)
        }
        if channel.status == .connected {
          Button(isMuted ? "Unmute" : "Mute", action: toggleMute)
        }
        if viewModel.emergencyChannel == channel {
          if viewModel.outgoingEmergency != nil {
            Button("Stop Emergency", action: stopEmergency)
          } else {
            Button("Start Emergency", action: startEmergency)
          }
        }
        if showEndCallButton {
          Button("End Call", action: endCall)
        }
        Button("Show History", action: showHistory)
      }
    }

    private func sendImage() {
      print("Send Image selected")
      if let image = UIImage(named: "TeamHonda") {
        viewModel.sendImage(channel: channel, image: image)
      }
    }

    private func sendLocation() {
      viewModel.sendLocationTo(channel: channel)
    }

    private func toggleMute() {
      viewModel.toggleMute(channel: channel)
    }

    private func startEmergency() {
      viewModel.startEmergency()
    }

    private func stopEmergency() {
      viewModel.stopEmergency()
    }

    private func showHistory() {
      viewModel.getHistory(channel: channel)
    }

    private func endCall() {
      viewModel.endCall(channel: channel)
    }
  }
}

#Preview {
  ChannelsView()
}

