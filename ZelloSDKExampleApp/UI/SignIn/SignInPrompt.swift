import SwiftUI
import ZelloSDK

struct SignInPrompt: View {
  @Binding var showDialog: Bool
  @Binding var credentials: ZelloCredentials
  let onConnect: () -> Void

  var body: some View {
      ZStack {
        Color.black.opacity(0.4)
          .edgesIgnoringSafeArea(.all)

        SignInView(
          credentials: $credentials,
          showDialog: $showDialog,
          onConnect: onConnect
        )
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
      }
      .animation(.easeInOut, value: showDialog)
  }
}
