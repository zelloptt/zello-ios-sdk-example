import SwiftUI

struct TabBar: View {
  var body: some View {
    TabView {
      RecentsView()
        .tabItem {
          Label("Recents", systemImage: "clock")
        }
      UsersView()
        .tabItem {
          Label("Users", systemImage: "person")
        }
      ChannelsView()
        .tabItem {
          Label("Channels", systemImage: "person.3")
        }
      ConversationsView()
        .tabItem {
          Label("Conversations", systemImage: "person.2")
        }
    }
  }
}

#Preview {
  TabBar()
}
