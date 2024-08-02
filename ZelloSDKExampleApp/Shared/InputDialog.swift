import SwiftUI
import ZelloSDK

enum InputAction: String {
  case alert = "Alert"
  case text = "Text"
}

struct InputDialog: View {
  @Binding var isVisible: Bool
  @Binding var text: String
  @Binding var selectedLevel: ZelloAlertMessage.ChannelLevel?
  let action: InputAction
  let contact: ZelloContact
  var onSend: () -> Void

  init(isVisible: Binding<Bool>,
       text: Binding<String>,
       selectedLevel: Binding<ZelloAlertMessage.ChannelLevel?> = .constant(nil),
       action: InputAction,
       contact: ZelloContact,
       onSend: @escaping () -> Void) {
    self._isVisible = isVisible
    self._text = text
    self._selectedLevel = selectedLevel
    self.action = action
    self.contact = contact
    self.onSend = onSend
  }

  var body: some View {
    VStack {
      Text("Send \(action) to \(contact.name)")
        .padding()

      TextField("Enter your message", text: $text)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()

      if selectedLevel != nil {
        Picker("Select Level", selection: $selectedLevel.unwrap(defaultValue: .connected)) {
          ForEach(ZelloAlertMessage.ChannelLevel.allCases, id: \.self) { level in
            Text(level.description).tag(level as ZelloAlertMessage.ChannelLevel?)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
      }

      HStack {
        Button("Cancel") {
          isVisible = false
        }
        .padding()

        Button("Send") {
          onSend()
          isVisible = false
        }
        .padding()
      }
    }
    .background(Color.white)
    .cornerRadius(8)
    .shadow(radius: 10)
    .padding()
  }
}

extension Binding where Value: ExpressibleByNilLiteral {
  func unwrap(defaultValue: Value) -> Binding<Value> {
    Binding<Value>(
      get: { self.wrappedValue },
      set: { newValue in self.wrappedValue = newValue }
    )
  }
}

extension ZelloAlertMessage.ChannelLevel: CaseIterable {
  public static var allCases: [Self] {
    return [.connected, .all]
  }

  var description: String {
    switch self {
    case .connected:
      return "Connected"
    case .all:
      return "All"
    @unknown default:
      return "?"
    }
  }
}
