import SwiftUI
import ZelloSDK

struct ImagePopupView: View {
  @Binding var isVisible: Bool
  var imageMessage: ZelloImageMessage?
  var sender: String?

  var body: some View {
    GeometryReader { geometry in
      if isVisible, let uiImage = imageMessage?.image {
        ZStack(alignment: .center) {
          Color.black.opacity(0.5)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
              isVisible = false
            }

          VStack {
            Spacer() // Center vertically
            VStack {
              if let sender = sender(imageMessage) {
                Text("From: \(sender)")
                  .font(.headline)
                  .padding(.top)
                  .foregroundColor(.black)
              }

              Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: scaledWidth(for: uiImage, in: geometry),
                       height: scaledHeight(for: uiImage, in: geometry))
                .clipped()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding(.horizontal, 10)

              Button("Close") {
                isVisible = false
              }
              .padding()
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(10)
              .padding(.top, 5)
              .padding(.bottom, 10)
            }
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            .padding(.horizontal, 10)
            Spacer()
          }
          .frame(maxWidth: geometry.size.width * 0.9)
          .padding(.horizontal, (geometry.size.width - geometry.size.width * 0.9) / 2)
        }
      }
    }
  }

  private func sender(_ imageMessage: ZelloImageMessage?) -> String? {
    guard let imageMessage else { return nil }

    if let author = imageMessage.channelUser {
      var displayName = imageMessage.contact.name
      if let conversation = imageMessage.contact.asZelloGroupConversation() {
        displayName = conversation.displayName
      }
      return "\(author.name) -> \(displayName)"
    }
    return imageMessage.contact.name
  }

  private func scaledWidth(for image: UIImage, in geometry: GeometryProxy) -> CGFloat {
    let imageAspectRatio = image.size.width / image.size.height
    let maxImageHeight = geometry.size.height * 0.9
    let maxImageWidth = geometry.size.width * 0.9
    let calculatedHeight = min(image.size.height, maxImageHeight)
    return min(image.size.width, calculatedHeight * imageAspectRatio, maxImageWidth)
  }

  private func scaledHeight(for image: UIImage, in geometry: GeometryProxy) -> CGFloat {
    let imageAspectRatio = image.size.width / image.size.height
    let maxImageHeight = (geometry.size.height * 0.9) - 44.0
    let maxImageWidth = geometry.size.width * 0.9
    let calculatedWidth = min(image.size.width, maxImageWidth)
    return min(image.size.height, calculatedWidth / imageAspectRatio, maxImageHeight)
  }
}

#Preview {
  ImagePopupView(isVisible: .constant(true), imageMessage: nil, sender: nil)
}
