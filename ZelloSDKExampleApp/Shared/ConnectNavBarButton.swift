import SwiftUI

struct ConnectNavBarButton<ViewModel: ConnectivityProvider>: View {
  @ObservedObject var viewModel: ViewModel
  let onConnectButtonTapped: () -> Void

  var body: some View {
    Button(action: toggleConnection) {
      if viewModel.isConnecting {
        Text("Connecting")
      } else {
        Text(viewModel.isConnected ? "Disconnect" : "Connect")
      }
    }
  }

  private func toggleConnection() {
    if viewModel.isConnected {
      viewModel.disconnect()
    } else {
      onConnectButtonTapped()
    }
  }
}
