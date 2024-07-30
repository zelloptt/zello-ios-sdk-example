import Combine
import ZelloSDK

class ChannelsViewModel: ObservableObject, ConnectivityProvider {
  @Published var channels: [ZelloChannel] = []
  @Published var connectionViewState: ConnectionViewState
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
  @Published var emergencyChannel: ZelloChannel?
  @Published var incomingEmergencies: [ZelloIncomingEmergency] = []
  @Published var outgoingEmergency: ZelloOutgoingEmergency?
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

    channels = ZelloRepository.instance.channels
    ZelloRepository.instance.$channels
      .sink { [weak self] channels in
        self?.channels = channels
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

    ZelloRepository.instance.$outgoingEmergency
      .sink { [weak self] outgoingEmergency in
        self?.outgoingEmergency = outgoingEmergency
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$incomingEmergencies
      .sink { [weak self] incomingEmergencies in
        self?.incomingEmergencies = incomingEmergencies
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$emergencyChannel
      .sink { [weak self] emergencyChannel in
        self?.emergencyChannel = emergencyChannel
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
    ZelloRepository.instance.sdk.connect(credentials:credentials)
  }

  func disconnect() {
    ZelloRepository.instance.sdk.disconnect()
  }

  func setSelectedContact(channel: ZelloChannel) {
    let contact = ZelloContact.zelloChannel(channel)
    ZelloRepository.instance.sdk.setSelectedContact(contact: contact)
  }

  func startSendingMessage(channel: ZelloChannel) {
    let contact = ZelloContact.zelloChannel(channel)
    ZelloRepository.instance.sdk.startVoiceMessage(contact: contact)
  }

  func stopSendingMessage() {
    ZelloRepository.instance.sdk.stopVoiceMessage()
  }

  func connectChannel(channel: ZelloChannel) {
    ZelloRepository.instance.sdk.connectChannel(channel: channel)
  }

  func disconnectChannel(channel: ZelloChannel) {
    ZelloRepository.instance.sdk.disconnectChannel(channel: channel)
  }

  func sendImage(channel: ZelloChannel, image: UIImage) {
    let contact = ZelloContact.zelloChannel(channel)
    ZelloRepository.instance.sdk.send(image, to: contact)
  }

  func setAccountStatus(status: ZelloAccountStatus) {
    ZelloRepository.instance.sdk.setAccountStatus(status: status)
  }

  func sendText(channel: ZelloChannel, message: String) {
    let contact = ZelloContact.zelloChannel(channel)
    ZelloRepository.instance.sdk.send(textMessage: message, to: contact)
  }

  func sendAlert(channel: ZelloChannel, message: String, level: ZelloChannelAlertLevel? = nil) {
    let contact = ZelloContact.zelloChannel(channel)
    ZelloRepository.instance.sdk.send(alertMessage: message, to: contact, using: level)
  }

  func sendLocationTo(channel: ZelloChannel) {
    let contact = ZelloContact.zelloChannel(channel)
    ZelloRepository.instance.sdk.sendLocation(to: contact)
  }

  func toggleMute(channel: ZelloChannel) {
    let contact = ZelloContact.zelloChannel(channel)
    contact.isMuted ? ZelloRepository.instance.sdk.unmuteContact(contact: contact) : ZelloRepository.instance.sdk.muteContact(contact: contact)
  }

  func startEmergency() {
    ZelloRepository.instance.sdk.startEmergency()
  }

  func stopEmergency() {
    ZelloRepository.instance.sdk.stopEmergency()
  }

  func getHistory(channel: ZelloChannel) {
    let contact = ZelloContact.zelloChannel(channel)
    ZelloRepository.instance.getHistory(contact: contact)
  }
}
