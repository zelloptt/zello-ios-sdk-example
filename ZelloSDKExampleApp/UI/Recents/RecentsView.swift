import SwiftUI
import ZelloSDK

struct RecentsView: View {
  @StateObject private var viewModel = RecentsViewModel()
  @State private var showSignInDialog = false
  @State private var credentials = ZelloCredentials(username: "", network: "", password: "")
  @State private var showStatusMenu = false

  var body: some View {
    NavigationView {
      ZStack {
        VStack {
          ScrollView {
            LazyVStack {
              ForEach(viewModel.recents, id: \.contact.name) { recent in
                HStack {
                  Details(viewModel: viewModel, recent: recent)
                }
                .cornerRadius(5)
              }
              .cornerRadius(5)
              .padding(.horizontal, 12)
              .padding(.vertical, 2)
            }
          }
          StatusMessageView(statusMessage: viewModel.statusMessage)
        }

        if showSignInDialog {
          SignInPrompt(
            showDialog: $showSignInDialog,
            credentials: $credentials
          ) {
            viewModel.connect(credentials: credentials)
          }
        }

        if viewModel.showImagePopup {
          ImagePopupView(isVisible: $viewModel.showImagePopup,
                         imageMessage: viewModel.incomingImageMessage)
        }

        if viewModel.showTextPopup {
          TextPopupView(isVisible: $viewModel.showTextPopup,
                         textMessage: viewModel.incomingTextMessage)
        }

        if viewModel.showAlertPopup {
          AlertPopupView(isVisible: $viewModel.showAlertPopup,
                         alertMessage: viewModel.incomingAlertMessage)
        }

        if viewModel.showLocationPopup {
          LocationPopupView(isVisible: $viewModel.showLocationPopup,
                         locationMessage: viewModel.incomingLocationMessage)
        }
      }
      .navigationTitle("Recents")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarItems(
        leading: viewModel.isConnected ? AnyView(StatusActionSheet(
          showStatusMenu: $showStatusMenu,
          accountStatus: $viewModel.accountStatus,
          updateAccountStatus: viewModel.setAccountStatus
        )) : AnyView(EmptyView()),
        trailing: ConnectNavBarButton(viewModel: viewModel, onConnectButtonTapped: {
          showSignInDialog = true
        })
      )
    }
  }

  private func updateAccountStatus(_ status: ZelloAccountStatus) {
    viewModel.setAccountStatus(status: status)
  }

  struct Details: View {
    @ObservedObject var viewModel: RecentsViewModel
    let recent: ZelloRecentEntry

    var recentName: String {
      if let channelUser = recent.channelUser?.name {
        return "\(channelUser) : \(recent.contact.name)"
      } else if let user = recent.contact.asZelloUser() {
        return "\(user.displayName) (\(user.name))"
      } else if let conversation = recent.contact.asZelloGroupConversation() {
        return conversation.displayName
      }
      return recent.contact.name
    }

    var body: some View {
      HStack {
        Image(systemName: recent.incoming ? "arrow.down" : "arrow.up")
          .padding(.trailing, 8)
        VStack(alignment: .leading) {
          Text(recentName)
          Text(recent.type.rawValue)
          Text(recent.timestamp.formatted())
        }.frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}

#Preview {
  RecentsView()
}
