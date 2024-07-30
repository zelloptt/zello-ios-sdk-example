import SwiftUI
import ZelloSDK
import CoreLocation
import MapKit

struct LocationPopupView: View {
  @Binding var isVisible: Bool
  var locationMessage: ZelloLocationMessage?
  var sender: String?

  var body: some View {
    GeometryReader { geometry in
      if isVisible, let message = locationMessage {
        ZStack(alignment: .center) {
          Color.black.opacity(0.5)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
              isVisible = false
            }

          VStack(spacing: 16) {
            if let sender = sender(locationMessage) {
              Text("From: \(sender)")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 8)
            }

            MapView(coordinate: message.location.coordinate)
              .frame(height: 200)
              .cornerRadius(10)

            if let address = message.address {
              Text("Address: \(address)")
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .foregroundColor(.black)
                .frame(maxWidth: geometry.size.width * 0.8)
            }

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

  private func sender(_ locationMessage: ZelloLocationMessage?) -> String? {
    guard let locationMessage else { return nil }

    if let author = locationMessage.channelUser {
      return "\(author.name) -> \(locationMessage.contact.name)"
    }
    return locationMessage.contact.name
  }
}
