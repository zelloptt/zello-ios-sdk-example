import ZelloSDK

struct ConnectionViewState {
  var connectionState: Zello.ConnectionState

  init(connectionState: Zello.ConnectionState) {
    self.connectionState = connectionState
  }
}
