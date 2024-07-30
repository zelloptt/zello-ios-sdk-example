import SwiftUI

struct ListItemTalkButton: View {
  let isSending: Bool
  let isReceiving: Bool
  let isConnecting: Bool
  let isEnabled: Bool
  let onDown: () -> Void
  let onUp: () -> Void

  @State private var isPressed = false

  var body: some View {
    Button(action: {}, label: {
      Text(isSending ? "Sending" : isReceiving ? "Receiving" : isConnecting ? "Connecting" : "PTT")
        .padding(8)
        .foregroundColor(.white)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(isSending ? Color.red : (isReceiving ? Color.green : Color.blue))
          )
    })
    .buttonStyle(PlainButtonStyle())
    .simultaneousGesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in
          isPressed = true
          onDown()
        }
        .onEnded { _ in
          isPressed = false
          onUp()
        }
    )
    .disabled(!isEnabled)
  }
}

#Preview {
  VStack {
    ListItemTalkButton(isSending: true, isReceiving: false, isConnecting: false, isEnabled: true, onDown: {}, onUp: {})
    ListItemTalkButton(isSending: false, isReceiving: true, isConnecting: false, isEnabled: true, onDown: {}, onUp: {})
    ListItemTalkButton(isSending: false, isReceiving: false, isConnecting: true, isEnabled: true, onDown: {}, onUp: {})
    ListItemTalkButton(isSending: false, isReceiving: false, isConnecting: false, isEnabled: false, onDown: {}, onUp: {})
  }
}
