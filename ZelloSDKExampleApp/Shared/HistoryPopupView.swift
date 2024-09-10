import SwiftUI
import ZelloSDK

struct HistoryPopupView: View {
  @Binding var isVisible: Bool
  var messages: [ZelloHistoryMessage]

  func getTitle(_ message: ZelloHistoryMessage) -> String {
    if let channelUser = message.channelUser?.name {
      return "\(channelUser) : \(message.contact.name)"
    } else if let user = message.contact.asZelloUser() {
      return "\(user.displayName) (\(user.name))"
    }
    return message.contact.name
  }

  var body: some View {
    GeometryReader { geometry in
      if isVisible {
        ZStack(alignment: .center) {
          Color.black.opacity(0.5)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
              isVisible = false
            }

          VStack(spacing: 16) {
            ScrollView {
              LazyVStack {
                ForEach(messages, id: \.historyId) { message in
                  HStack {
                    Image(systemName: message.incoming ? "arrow.down" : "arrow.up")
                      .padding(.trailing, 8)
                    VStack(alignment: .leading) {
                      Text(getTitle(message))
                      Text(String(describing: type(of: message)))
                      Text(message.timestamp.formatted())
                      if let voiceMessage = message as? ZelloHistoryVoiceMessage {
                        Text("\(voiceMessage.duration) seconds")
                      } else if let imageMessage = message as? ZelloHistoryImageMessage,
                         let message = ZelloRepository.instance.zello.loadHistoryImage(for: imageMessage) {
                        Image(uiImage: message)
                      } else if let locationMessage = message as? ZelloHistoryLocationMessage {
                        MapView(coordinate: locationMessage.location.coordinate)
                          .frame(height: 200)
                          .cornerRadius(10)
                      } else if let textMessage = message as? ZelloHistoryTextMessage {
                        Text(textMessage.text)
                      } else if let alertMessage = message as? ZelloHistoryAlertMessage {
                        Text(alertMessage.text)
                      }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                  }
                  .onTapGesture {
                    if let voiceMessage = message as? ZelloHistoryVoiceMessage {
                      if ZelloRepository.instance.activeHistoryVoiceMessage != nil {
                        ZelloRepository.instance.zello.stopHistoryMessagePlayback()
                      } else {
                        ZelloRepository.instance.zello.playHistoryMessage(voiceMessage)
                      }
                    }
                  }
                  .background(.gray.opacity(0.2))
                }
                .cornerRadius(5)
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
              }
            }

            Button("Close") {
              ZelloRepository.instance.clearHistory()
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
}
