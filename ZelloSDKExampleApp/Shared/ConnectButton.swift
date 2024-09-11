import SwiftUI

struct ConnectButton<ViewModel: ConnectivityProvider>: View {
  @ObservedObject var viewModel: ViewModel
  let onConnectButtonTapped: () -> Void

  var body: some View {
    let isConnected = viewModel.isConnected
    let isConnecting = viewModel.isConnecting

    SessionConnectButton(isConnected: isConnected, isConnecting: isConnecting) {
      if isConnected {
        viewModel.disconnect()
      } else {
        onConnectButtonTapped()
      }
    }
  }
}
