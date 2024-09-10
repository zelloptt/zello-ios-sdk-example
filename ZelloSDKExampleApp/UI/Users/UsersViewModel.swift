import Combine
import UIKit
import ZelloSDK

class UsersViewModel: ObservableObject, ConnectivityProvider {
  @Published var users: [ZelloUser] = []
  @Published var connectionViewState: ConnectionViewState
  @Published var statusMessage: String?
  @Published var selectedContact: ZelloContact? = nil
  @Published var outgoingVoiceMessageViewState: OutgoingVoiceMessageViewState?
  @Published var incomingVoiceMessageViewState: IncomingVoiceMessageViewState?
  @Published var showImagePopup = false
  @Published var showTextPopup = false
  @Published var showLocationPopup = false
  @Published var showAlertPopup = false
  @Published var showHistoryPopup = false
  @Published var incomingImageMessage: ZelloImageMessage?
  @Published var incomingTextMessage: ZelloTextMessage?
  @Published var incomingAlertMessage: ZelloAlertMessage?
  @Published var incomingLocationMessage: ZelloLocationMessage?
  @Published var accountStatus: ZelloAccountStatus?
  @Published var history: HistoryViewState? = nil

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
          self?.incomingImageMessage = nil
        } else {
          self?.incomingImageMessage = incomingImageMessage
          self?.showImagePopup = incomingImageMessage != nil
        }
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingTextMessage
      .sink { [weak self] incomingTextMessage in
        if incomingTextMessage?.channelUser != nil {
          self?.incomingTextMessage = nil
        } else {
          self?.incomingTextMessage = incomingTextMessage
          self?.showTextPopup = incomingTextMessage != nil
        }
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingLocationMessage
      .sink { [weak self] incomingLocationMessage in
        if incomingLocationMessage?.channelUser != nil {
          self?.incomingLocationMessage = nil
        } else {
          self?.incomingLocationMessage = incomingLocationMessage
          self?.showLocationPopup = incomingLocationMessage != nil
        }
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingAlertMessage
      .sink { [weak self] incomingAlertMessage in
        if incomingAlertMessage?.channelUser != nil {
          self?.incomingAlertMessage = nil
        } else {
          self?.incomingAlertMessage = incomingAlertMessage
          self?.showAlertPopup = incomingAlertMessage != nil
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
  }

  func connect(credentials: ZelloCredentials) {
    ZelloRepository.instance.zello.connect(credentials: credentials)
  }

  func disconnect() {
    ZelloRepository.instance.zello.disconnect()
  }

  func setSelectedContact(user: ZelloUser) {
    let contact = ZelloContact.user(user)
    ZelloRepository.instance.zello.setSelectedContact(contact: contact)
  }

  func startSendingMessage(user: ZelloUser) {
    let contact = ZelloContact.user(user)
    ZelloRepository.instance.zello.startVoiceMessage(contact: contact)
  }

  func stopSendingMessage() {
    ZelloRepository.instance.zello.stopVoiceMessage()
  }

  func sendImage(user: ZelloUser, image: UIImage) {
    let contact = ZelloContact.user(user)
    ZelloRepository.instance.zello.send(image, to: contact)
  }

  func sendText(user: ZelloUser, message: String) {
    let contact = ZelloContact.user(user)
    ZelloRepository.instance.zello.send(textMessage: message, to: contact)
  }

  func sendAlert(user: ZelloUser, message: String) {
    let contact = ZelloContact.user(user)
    ZelloRepository.instance.zello.send(alertMessage: message, to: contact, using: nil)
  }

  func setAccountStatus(status: ZelloAccountStatus) {
    ZelloRepository.instance.zello.setAccountStatus(status: status)
  }

  func sendLocationTo(user: ZelloUser) {
    let contact = ZelloContact.user(user)
    ZelloRepository.instance.zello.sendLocation(to: contact)
  }

  func toggleMute(user: ZelloUser) {
    let contact = ZelloContact.user(user)
    contact.isMuted ? ZelloRepository.instance.zello.unmuteContact(contact: contact) : ZelloRepository.instance.zello.muteContact(contact: contact)
  }

  func getHistory(user: ZelloUser) {
    let contact = ZelloContact.user(user)
    ZelloRepository.instance.getHistory(contact: contact)
  }
}
