import SwiftUI
import ZelloSDK

struct SignInView: View {
  @Binding var credentials: ZelloCredentials
  @Binding var showDialog: Bool
  let onConnect: () -> Void

  private var passwordBinding: Binding<String> {
    Binding<String>(
      get: { self.credentials.password ?? "" },
      set: { self.credentials.password = $0 }
    )
  }

  var body: some View {
    VStack(spacing: 16) {
      Text("Enter Credentials")
        .font(.headline)

      TextField("Username", text: $credentials.username)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .padding(.horizontal)

      SecureField("Password", text: passwordBinding)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .padding(.horizontal)

      TextField("Network", text: $credentials.network)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .padding(.horizontal)

      HStack {
        Button("Cancel") {
          showDialog = false
        }
        .foregroundColor(.gray)
        .padding()

        Spacer()

        Button("Sign In") {
          showDialog = false
          onConnect()
        }
        .foregroundColor(.blue)
        .padding()
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(8)
    .shadow(radius: 10)
    .frame(maxWidth: 300)
  }
}
