import Combine
import UIKit
import ZelloSDK

class ConversationsViewModel: ObservableObject, ConnectivityProvider {
  @Published var connectionViewState: ConnectionViewState
  @Published var groupConversations: [ZelloGroupConversation] = []
  @Published var users: [ZelloUser] = []
  @Published var statusMessage: String?
  @Published var selectedContact: ZelloContact? = nil
  @Published var outgoingVoiceMessageViewState: OutgoingVoiceMessageViewState?
  @Published var incomingVoiceMessageViewState: IncomingVoiceMessageViewState?
  @Published var incomingImageMessage: ZelloImageMessage?
  @Published var incomingLocationMessage: ZelloLocationMessage?
  @Published var incomingTextMessage: ZelloTextMessage?
  @Published var incomingAlertMessage: ZelloAlertMessage?
  @Published var accountStatus: ZelloAccountStatus? = nil
  @Published var showLocationPopup = false
  @Published var showTextPopup = false
  @Published var showImagePopup = false
  @Published var showAlertPopup = false
  @Published var showHistoryPopup = false
  @Published var history: HistoryViewState? = nil
  @Published var settings: ZelloConsoleSettings? = nil

  private var cancellables: Set<AnyCancellable> = []

  var isConnected: Bool {
    connectionViewState.connectionState == .connected
  }

  var isConnecting: Bool {
    connectionViewState.connectionState == .connecting
  }
  
  init() {
    connectionViewState = ConnectionViewState(connectionState: ZelloRepository.instance.connectionState)
    ZelloRepository.instance.$connectionState
      .sink { [weak self] connectionState in
        guard let weakSelf = self else { return }
        var state = weakSelf.connectionViewState
        state.connectionState = connectionState
        weakSelf.connectionViewState = state
      }
      .store(in: &cancellables)

    groupConversations = ZelloRepository.instance.groupConversations
    ZelloRepository.instance.$groupConversations
      .sink { [weak self] groupConversations in
        self?.groupConversations = groupConversations
      }
      .store(in: &cancellables)

    users = ZelloRepository.instance.users
    ZelloRepository.instance.$users
      .sink { [weak self] users in
        self?.users = users
      }
      .store(in: &cancellables)

    statusMessage = ZelloRepository.instance.statusMessage
    ZelloRepository.instance.$statusMessage
      .sink { [weak self] statusMessage in
        self?.statusMessage = statusMessage
      }
      .store(in: &cancellables)

    selectedContact = ZelloRepository.instance.selectedContact
    ZelloRepository.instance.$selectedContact
      .sink { [weak self] selectedContact in
        self?.selectedContact = selectedContact
      }
      .store(in: &cancellables)

    if let message = ZelloRepository.instance.outgoingVoiceMessage {
      outgoingVoiceMessageViewState = OutgoingVoiceMessageViewState(contact: message.contact, state: message.state)
    }
    ZelloRepository.instance.$outgoingVoiceMessage
      .sink { [weak self] outgoingVoiceMessage in
        if let message = outgoingVoiceMessage {
          self?.outgoingVoiceMessageViewState = OutgoingVoiceMessageViewState(contact: message.contact, state: message.state)
        } else {
          self?.outgoingVoiceMessageViewState = nil
        }
      }
      .store(in: &cancellables)

    if let message = ZelloRepository.instance.incomingVoiceMessage {
      incomingVoiceMessageViewState = IncomingVoiceMessageViewState(contact: message.contact)
    }
    ZelloRepository.instance.$incomingVoiceMessage
      .sink { [weak self] incomingVoiceMessage in
        if let message = incomingVoiceMessage {
          self?.incomingVoiceMessageViewState = IncomingVoiceMessageViewState(contact: message.contact)
        } else {
          self?.incomingVoiceMessageViewState = nil
        }
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingImageMessage
      .sink { [weak self] incomingImageMessage in
        if incomingImageMessage?.channelUser != nil {
          self?.incomingImageMessage = incomingImageMessage
          self?.showImagePopup = incomingImageMessage != nil
        } else {
          self?.incomingImageMessage = nil
        }
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingTextMessage
      .sink { [weak self] incomingTextMessage in
        if incomingTextMessage?.channelUser != nil {
          self?.incomingTextMessage = incomingTextMessage
          self?.showTextPopup = incomingTextMessage != nil
        } else {
          self?.incomingTextMessage = nil
        }
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingAlertMessage
      .sink { [weak self] incomingAlertMessage in
        if incomingAlertMessage?.channelUser != nil {
          self?.incomingAlertMessage = incomingAlertMessage
          self?.showAlertPopup = incomingAlertMessage != nil
        } else {
          self?.incomingAlertMessage = nil
        }
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingLocationMessage
      .sink { [weak self] incomingLocationMessage in
        if incomingLocationMessage?.channelUser != nil {
          self?.incomingLocationMessage = incomingLocationMessage
          self?.showLocationPopup = incomingLocationMessage != nil
        } else {
          self?.incomingLocationMessage = nil
        }
      }
      .store(in: &cancellables)

    accountStatus = ZelloRepository.instance.accountStatus
    ZelloRepository.instance.$accountStatus
      .sink { [weak self] accountStatus in
        self?.accountStatus = accountStatus
      }
      .store(in: &cancellables)

    history = ZelloRepository.instance.history
    ZelloRepository.instance.$history
      .sink { [weak self] history in
        self?.showHistoryPopup = history != nil
        self?.history = history
      }
      .store(in: &cancellables)

    settings = ZelloRepository.instance.settings
    ZelloRepository.instance.$settings
      .sink { [weak self] settings in
        self?.settings = settings
      }
      .store(in: &cancellables)
  }

  func connect(credentials: ZelloSDK.ZelloCredentials) {
    ZelloRepository.instance.zello.connect(credentials: credentials)
  }
  
  func disconnect() {
    ZelloRepository.instance.zello.disconnect()
  }

  func setSelectedContact(conversation: ZelloGroupConversation) {
    let contact = ZelloContact.conversation(conversation)
    ZelloRepository.instance.zello.setSelectedContact(contact: contact)
  }

  func startSendingMessage(conversation: ZelloGroupConversation) {
    let contact = ZelloContact.conversation(conversation)
    ZelloRepository.instance.zello.startVoiceMessage(contact: contact)
  }

  func stopSendingMessage() {
    ZelloRepository.instance.zello.stopVoiceMessage()
  }

  func connect(to conversation: ZelloGroupConversation) {
    ZelloRepository.instance.zello.connect(to: conversation)
  }

  func disconnect(from conversation: ZelloGroupConversation) {
    ZelloRepository.instance.zello.disconnect(from: conversation)
  }

  func sendImage(conversation: ZelloGroupConversation, image: UIImage) {
    let contact = ZelloContact.conversation(conversation)
    ZelloRepository.instance.zello.send(image, to: contact)
  }

  func setAccountStatus(status: ZelloAccountStatus) {
    ZelloRepository.instance.zello.setAccountStatus(status: status)
  }

  func sendText(conversation: ZelloGroupConversation, message: String) {
    let contact = ZelloContact.conversation(conversation)
    ZelloRepository.instance.zello.send(textMessage: message, to: contact)
  }

  func sendAlert(conversation: ZelloGroupConversation, message: String, level: ZelloAlertMessage.ChannelLevel? = nil) {
    let contact = ZelloContact.conversation(conversation)
    ZelloRepository.instance.zello.send(alertMessage: message, to: contact, using: level)
  }

  func sendLocationTo(conversation: ZelloGroupConversation) {
    let contact = ZelloContact.conversation(conversation)
    ZelloRepository.instance.zello.sendLocation(to: contact)
  }

  func rename(_ conversation: ZelloGroupConversation, to newName: String) {
    ZelloRepository.instance.zello.rename(conversation, to: newName)
  }

  func createConversation(users: [ZelloUser]) {
    ZelloRepository.instance.zello.createGroupConversation(users: users, displayName: nil)
  }

  func add(_ users: [ZelloUser], to conversation: ZelloGroupConversation) {
    ZelloRepository.instance.zello.add(users, to: conversation)
  }

  func toggleMute(conversation: ZelloGroupConversation) {
    let contact = ZelloContact.conversation(conversation)
    contact.isMuted ? ZelloRepository.instance.zello.unmuteContact(contact: contact) : ZelloRepository.instance.zello.muteContact(contact: contact)
  }

  func getHistory(conversation: ZelloGroupConversation) {
    let contact = ZelloContact.conversation(conversation)
    ZelloRepository.instance.getHistory(contact: contact)
  }

  func leave(_ conversation: ZelloGroupConversation) {
    ZelloRepository.instance.zello.leave(conversation)
  }

}
