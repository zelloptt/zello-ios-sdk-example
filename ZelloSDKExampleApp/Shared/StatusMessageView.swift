import SwiftUI

struct StatusMessageView: View {
  let statusMessage: String?

  var body: some View {
    if let statusMessage = statusMessage {
      Text(statusMessage)
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .transition(.scale)
    }
  }
}
