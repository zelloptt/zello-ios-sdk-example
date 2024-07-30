import Foundation
import Combine
import ZelloSDK

class ZelloRepository: ZelloSdk.Delegate, ObservableObject {

  static let instance = ZelloRepository()

  let sdk = ZelloSdk()

  @Published var connectionState: ZelloConnectionState = .disconnected
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

  init() {
    sdk.delegate = self
  }

  func zelloDidStartConnecting(_ sdk: ZelloSdk) {
    connectionState = sdk.connectionState
  }

  func zelloDidFinishConnecting(_ sdk: ZelloSdk) {
    connectionState = sdk.connectionState
  }

  func zello(_ sdk: ZelloSdk, didFailToConnect error: ZelloConnectionError) {
    connectionState = sdk.connectionState
    statusMessage = "Failed to connect \(error.localizedDescription)"
  }

  func zelloDidDisconnect(_ sdk: ZelloSdk) {
    connectionState = sdk.connectionState
  }

  func zelloWillReconnect(_ sdk: ZelloSdk) { }

  func zelloDidUpdateContactList(_ sdk: ZelloSdk) {
    users = sdk.users
    channels = sdk.channels
    emergencyChannel = sdk.emergencyChannel
  }

  func zello(_ sdk: ZelloSdk, accountStatusChangedTo newStatus: ZelloAccountStatus?) {
    accountStatus = newStatus
  }

  func zello(_ sdk: ZelloSdk, didUpdateSelectedContact contact: ZelloContact) {
    selectedContact = contact
  }

  func zello(_ sdk: ZelloSdk, didStartConnecting outgoingVoiceMessage: ZelloOutgoingVoiceMessage) {
    self.outgoingVoiceMessage = outgoingVoiceMessage
  }

  func zello(_ sdk: ZelloSdk, didStartSending outgoingVoiceMessage: ZelloOutgoingVoiceMessage) {
    self.outgoingVoiceMessage = outgoingVoiceMessage
  }

  func zello(_ sdk: ZelloSdk, didFinishSending outgoingVoiceMessage: ZelloOutgoingVoiceMessage, error: ZelloOutgoingVoiceMessageError?) {
    if let error {
      statusMessage = "Failed to send message \(error.localizedDescription)"
    }
    self.outgoingVoiceMessage = nil
  }

  func zello(_ sdk: ZelloSdk, didStartReceiving incomingVoiceMessage: ZelloIncomingVoiceMessage) {
    self.incomingVoiceMessage = incomingVoiceMessage
  }

  func zello(_ sdk: ZelloSdk, didFinishReceiving incomingVoiceMessage: ZelloIncomingVoiceMessage) {
    self.incomingVoiceMessage = nil
  }

  func zello(_ sdk: ZelloSdk, didReceive imageMessage: ZelloImageMessage) {
    self.lastIncomingImageMessage = imageMessage
  }

  func zello(_ sdk: ZelloSdk, didSend imageMessage: ZelloImageMessage) {
    print("sent image message")
  }

  func zello(_ sdk: ZelloSdk, didFailToSend imageMessage: ZelloImageMessage) {
    statusMessage = "Failed to send image message"
  }

  func zello(_ sdk: ZelloSdk, didReceive textMessage: ZelloTextMessage) {
    self.lastIncomingTextMessage = textMessage
  }

  func zello(_ sdk: ZelloSdk, didSend textMessage: ZelloTextMessage) {
    print("sent text message")
  }

  func zello(_ sdk: ZelloSdk, didFailToSend textMessage: ZelloTextMessage) {
    statusMessage = "Failed to send image message"
  }

  func zello(_ sdk: ZelloSdk, didReceive locationMessage: ZelloLocationMessage) {
    self.lastIncomingLocationMessage = locationMessage
  }

  func zello(_ sdk: ZelloSDK.ZelloSdk, didSend locationMessage: ZelloSDK.ZelloLocationMessage) {
    print("sent location message")
  }

  func zello(_ sdk: ZelloSdk, didFailToSend locationMessage: ZelloLocationMessage) {
    statusMessage = "Failed to send image message"
  }

  func zello(_ sdk: ZelloSdk, didReceive alertMessage: ZelloAlertMessage) {
    self.lastIncomingAlertMessage = alertMessage
  }

  func zello(_ sdk: ZelloSDK.ZelloSdk, didSend alertMessage: ZelloSDK.ZelloAlertMessage) {
    print("sent alert message")
  }

  func zello(_ sdk: ZelloSdk, didFailToSend alertMessage: ZelloAlertMessage) {
    statusMessage = "Failed to send image message"
  }

  func zello(_ sdk: ZelloSDK.ZelloSdk, didStart outgoingEmergency: ZelloSDK.ZelloOutgoingEmergency) {
    self.outgoingEmergency = sdk.outgoingEmergency
  }

  func zello(_ sdk: ZelloSDK.ZelloSdk, didStop outgoingEmergency: ZelloSDK.ZelloOutgoingEmergency) {
    self.outgoingEmergency = sdk.outgoingEmergency
  }

  func zello(_ sdk: ZelloSDK.ZelloSdk, didStart incomingEmergency: ZelloSDK.ZelloIncomingEmergency) {
    incomingEmergencies = sdk.incomingEmergencies
  }

  func zello(_ sdk: ZelloSDK.ZelloSdk, didStop incomingEmergency: ZelloSDK.ZelloIncomingEmergency) {
    incomingEmergencies = sdk.incomingEmergencies
  }

  func zello(_ sdk: ZelloSdk, didUpdate recentEntries: [ZelloRecentEntry]) {
    self.recents = recentEntries
  }

  func zelloDidUpdateHistory(_ sdk: ZelloSdk) {
    if let history {
      getHistory(contact: history.contact)
    }
  }

  func zello(_ sdk: ZelloSdk, didStartHistoryPlayback message: ZelloHistoryVoiceMessage) {
    activeHistoryVoiceMessage = message
  }

  func zello(_ sdk: ZelloSdk, didStopHistoryPlayback message: ZelloHistoryVoiceMessage) {
    activeHistoryVoiceMessage = nil
  }

  func getHistory(contact: ZelloContact) {
    history = HistoryViewState(contact: contact, messages: sdk.getHistory(contact: contact))
  }

  func clearHistory() {
    history = nil
  }
}
