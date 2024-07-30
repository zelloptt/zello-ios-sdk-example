import SwiftUI
import ZelloSDK

struct AlertPopupView: View {
  @Binding var isVisible: Bool
  var alertMessage: ZelloAlertMessage?
  var sender: String?

  var body: some View {
    GeometryReader { geometry in
      if isVisible, let message = alertMessage?.text {
        ZStack(alignment: .center) {
          Color.black.opacity(0.5)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
              isVisible = false
            }

          VStack(spacing: 16) {
            if let sender = sender(alertMessage) {
              Text("Alert from: \(sender)")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 8)
            }

            Text(message)
              .padding()
              .background(Color.white)
              .cornerRadius(10)
              .foregroundColor(.black)
              .frame(maxWidth: geometry.size.width * 0.8)


            Button("Close") {
              isVisible = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
          }
          .padding()
          .background(Color.white)
          .cornerRadius(15)
          .shadow(radius: 20)
          .padding(.horizontal, 20)
        }
      }
    }
  }

  private func sender(_ alertMessage: ZelloAlertMessage?) -> String? {
    guard let alertMessage else { return nil }

    if let author = alertMessage.channelUser {
      return "\(author.name) -> \(alertMessage.contact.name)"
    }
    return alertMessage.contact.name
  }
}
