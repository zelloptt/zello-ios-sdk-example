import UserNotifications
import os.log
import ZelloSDK

class NotificationService: UNNotificationServiceExtension {
  private var processingTask: Task<Void, Never>?

  override init() {
    super.init()
    Zello.setAppGroup("group.com.yourCompany.shared")
  }

  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    guard let content = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
      contentHandler(request.content)
      return
    }

    processingTask = Task {
      if let modifiedContent = await Zello.processNotification(request: request) {
        contentHandler(modifiedContent)
      } else {
        contentHandler(content)
      }
    }
  }

  override func serviceExtensionTimeWillExpire() {
    processingTask?.cancel()
    os_log("Service extension time will expire. Task was canceled.", log: OSLog.default, type: .info)
  }
}
