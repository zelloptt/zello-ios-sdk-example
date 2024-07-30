import ZelloSDK

struct ConnectionViewState {
  var connectionState: ZelloConnectionState

  init(connectionState: ZelloConnectionState) {
    self.connectionState = connectionState
  }
}
