import SwiftUI
import ZelloSDK

protocol ConnectivityProvider: ObservableObject {
  var isConnected: Bool { get }
  var isConnecting: Bool { get }
  func connect(credentials: ZelloCredentials)
  func disconnect()
}
