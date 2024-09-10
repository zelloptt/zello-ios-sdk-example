import Foundation
import Combine
import ZelloSDK

class ZelloRepository: Zello.Delegate, ObservableObject {

  static let instance = ZelloRepository()

  let zello = Zello.shared

  @Published var connectionState: Zello.ConnectionState = .disconnected
  @Published var users: [ZelloUser] = []
  @Published var channels: [ZelloChannel] = []
  @Published var selectedContact: ZelloContact? = nil
  @Published var statusMessage: String? = nil {
    didSet {
      // Sets the statusMessage for 3 seconds, then clears it out
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
        guard let self = self else { return }
        if statusMessage != nil {
          statusMessage = nil
        }
      }
    }
  }
  @Published var outgoingVoiceMessage: ZelloOutgoingVoiceMessage? = nil
  @Published var incomingVoiceMessage: ZelloIncomingVoiceMessage? = nil
  @Published var lastIncomingImageMessage: ZelloImageMessage? = nil
  @Published var lastIncomingTextMessage: ZelloTextMessage? = nil
  @Published var lastIncomingLocationMessage: ZelloLocationMessage? = nil
  @Published var lastIncomingAlertMessage: ZelloAlertMessage? = nil
  @Published var accountStatus: ZelloAccountStatus? = nil
  @Published var emergencyChannel: ZelloChannel? = nil
  @Published var incomingEmergencies: [ZelloIncomingEmergency] = []
  @Published var outgoingEmergency: ZelloOutgoingEmergency? = nil
  @Published var recents: [ZelloRecentEntry] = []
  @Published var history: HistoryViewState? = nil
  @Published var activeHistoryVoiceMessage: ZelloHistoryVoiceMessage? = nil
  @Published var settings: ZelloConsoleSettings? = nil

  init() {
    zello.delegate = self
    var configuration = ZelloConfiguration(appGroup: "group.com.yourCompany.shared")
    #if DEBUG
    configuration.pushNotificationEnvironment = .development
    #endif
    zello.configuration = configuration
  }

  func zelloDidStartConnecting(_ zello: Zello) {
    connectionState = zello.connectionState
  }

  func zelloDidFinishConnecting(_ zello: Zello) {
    connectionState = zello.connectionState
  }

  func zello(_ zello: Zello, didFailToConnect error: Zello.ConnectionError) {
    connectionState = zello.connectionState
    statusMessage = "Failed to connect \(error.localizedDescription)"
  }

  func zelloDidDisconnect(_ zello: Zello) {
    connectionState = zello.connectionState
  }

  func zelloWillReconnect(_ zello: Zello) { }

  func zelloDidUpdateContactList(_ zello: Zello) {
    users = zello.users
    channels = zello.channels
    emergencyChannel = zello.emergencyChannel
  }

  func zello(_ zello: Zello, accountStatusChangedTo newStatus: ZelloAccountStatus?) {
    accountStatus = newStatus
  }

  func zello(_ zello: Zello, didUpdateSelectedContact contact: ZelloContact) {
    selectedContact = contact
  }

  func zello(_ zello: Zello, didStartConnecting outgoingVoiceMessage: ZelloOutgoingVoiceMessage) {
    self.outgoingVoiceMessage = outgoingVoiceMessage
  }

  func zello(_ zello: Zello, didStartSending outgoingVoiceMessage: ZelloOutgoingVoiceMessage) {
    self.outgoingVoiceMessage = outgoingVoiceMessage
  }

  func zello(_ zello: Zello, didFinishSending outgoingVoiceMessage: ZelloOutgoingVoiceMessage, error: ZelloOutgoingVoiceMessage.Error?) {
    if let error {
      statusMessage = "Failed to send message \(error.localizedDescription)"
    }
    self.outgoingVoiceMessage = nil
  }

  func zello(_ zello: Zello, didStartReceiving incomingVoiceMessage: ZelloIncomingVoiceMessage) {
    self.incomingVoiceMessage = incomingVoiceMessage
  }

  func zello(_ zello: Zello, didFinishReceiving incomingVoiceMessage: ZelloIncomingVoiceMessage) {
    self.incomingVoiceMessage = nil
  }

  func zello(_ zello: Zello, didReceive imageMessage: ZelloImageMessage) {
    self.lastIncomingImageMessage = imageMessage
  }

  func zello(_ zello: Zello, didSend imageMessage: ZelloImageMessage) {
    print("sent image message")
  }

  func zello(_ zello: Zello, didFailToSend imageMessage: ZelloImageMessage) {
    statusMessage = "Failed to send image message"
  }

  func zello(_ zello: Zello, didReceive textMessage: ZelloTextMessage) {
    self.lastIncomingTextMessage = textMessage
  }

  func zello(_ zello: Zello, didSend textMessage: ZelloTextMessage) {
    print("sent text message")
  }

  func zello(_ zello: Zello, didFailToSend textMessage: ZelloTextMessage) {
    statusMessage = "Failed to send image message"
  }

  func zello(_ zello: Zello, didReceive locationMessage: ZelloLocationMessage) {
    self.lastIncomingLocationMessage = locationMessage
  }

  func zello(_ zello: Zello, didSend locationMessage: ZelloLocationMessage) {
    print("sent location message")
  }

  func zello(_ zello: Zello, didFailToSend locationMessage: ZelloLocationMessage) {
    statusMessage = "Failed to send image message"
  }

  func zello(_ zello: Zello, didReceive alertMessage: ZelloAlertMessage) {
    self.lastIncomingAlertMessage = alertMessage
  }

  func zello(_ zello: Zello, didSend alertMessage: ZelloAlertMessage) {
    print("sent alert message")
  }

  func zello(_ zello: Zello, didFailToSend alertMessage: ZelloAlertMessage) {
    statusMessage = "Failed to send image message"
  }

  func zello(_ zello: Zello, didStart outgoingEmergency: ZelloOutgoingEmergency) {
    self.outgoingEmergency = zello.outgoingEmergency
  }

  func zello(_ zello: Zello, didStop outgoingEmergency: ZelloOutgoingEmergency) {
    self.outgoingEmergency = zello.outgoingEmergency
  }

  func zello(_ zello: Zello, didStart incomingEmergency: ZelloIncomingEmergency) {
    incomingEmergencies = zello.incomingEmergencies
  }

  func zello(_ zello: Zello, didStop incomingEmergency: ZelloIncomingEmergency) {
    incomingEmergencies = zello.incomingEmergencies
  }

  func zello(_ zello: Zello, didUpdate recentEntries: [ZelloRecentEntry]) {
    self.recents = recentEntries
  }

  func zelloDidUpdateHistory(_ zello: Zello) {
    if let history {
      getHistory(contact: history.contact)
    }
  }

  func zello(_ zello: Zello, didStartHistoryPlayback message: ZelloHistoryVoiceMessage) {
    activeHistoryVoiceMessage = message
  }

  func zello(_ zello: Zello, didFinishHistoryPlayback message: ZelloHistoryVoiceMessage) {
    activeHistoryVoiceMessage = nil
  }

  func zello(_ zello: Zello, didUpdate settings: ZelloConsoleSettings) {
    self.settings = settings
  }

  func getHistory(contact: ZelloContact) {
    history = HistoryViewState(contact: contact, messages: zello.getHistory(contact: contact))
  }

  func clearHistory() {
    history = nil
  }
}
