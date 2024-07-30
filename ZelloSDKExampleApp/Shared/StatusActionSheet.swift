import SwiftUI
import ZelloSDK

struct StatusActionSheet: View {
  @Binding var showStatusMenu: Bool
  @Binding var accountStatus: ZelloAccountStatus?
  var updateAccountStatus: (ZelloAccountStatus) -> Void

  var body: some View {
    Button("Status", action: { showStatusMenu = true })
      .actionSheet(isPresented: $showStatusMenu) {
        ActionSheet(
          title: Text("Select Your Status"),
          buttons: [
            .default(Text("Available" + (accountStatus == .available ? " ✔︎" : ""))) {
              updateAccountStatus(.available)
            },
            .default(Text("Busy" + (accountStatus == .busy ? " ✔︎" : ""))) {
              updateAccountStatus(.busy)
            },
            .cancel()
          ]
        )
      }
  }
}
