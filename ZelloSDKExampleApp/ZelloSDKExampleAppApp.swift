import SwiftUI

@main
struct ZelloSDKExampleAppApp: App {
  @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
  
  var body: some Scene {
    WindowGroup {
      TabBar()
    }
  }
}
