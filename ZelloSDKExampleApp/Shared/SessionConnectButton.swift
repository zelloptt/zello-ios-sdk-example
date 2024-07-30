import SwiftUI

struct SessionConnectButton: View {
  let isConnected: Bool
  let isConnecting: Bool
  let onClick: () -> Void

  var body: some View {
    Button(isConnected ? "Disconnect" : isConnecting ? "Connecting" : "Connect", action: {
      onClick()
    }).disabled(isConnecting)
  }
}
