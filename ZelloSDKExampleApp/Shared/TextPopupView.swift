import SwiftUI
import ZelloSDK

struct TextPopupView: View {
  @Binding var isVisible: Bool
  var textMessage: ZelloTextMessage?
  var sender: String?

  var body: some View {
    GeometryReader { geometry in
      if isVisible, let message = textMessage?.text {
        ZStack(alignment: .center) {
          Color.black.opacity(0.5)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
              isVisible = false
            }

          VStack(spacing: 16) {
            if let sender = sender(textMessage) {
              Text("Text from: \(sender)")
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

  private func sender(_ textMessage: ZelloTextMessage?) -> String? {
    guard let textMessage else { return nil }

    if let author = textMessage.channelUser {
      var displayName = textMessage.contact.name
      if let conversation = textMessage.contact.asZelloGroupConversation() {
        displayName = conversation.displayName
      }
      return "\(author.name) -> \(displayName)"
    }
    return textMessage.contact.name
  }
}
