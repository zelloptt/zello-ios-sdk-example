import UIKit
import AVFAudio
import CoreBluetooth
import CoreLocation

class AppDelegate: NSObject, UIApplicationDelegate {
  var centralManager: CBCentralManager?
  var locationManager: CLLocationManager?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    requestNotificationPermission()
    requestMicrophonePermission()
    requestBluetoothPermission()
    requestLocationPermission()
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    ZelloRepository.instance.zello.registerForRemoteNotifications(deviceToken: deviceToken)
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
  }

  private func requestNotificationPermission() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.sound, .alert, .badge]) { success, _ in
      DispatchQueue.main.async {
        if success {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
  }

  private func requestMicrophonePermission() {
    if #available(iOS 17, *) {
      AVAudioApplication.requestRecordPermission { granted in }
    } else {
      AVAudioSession.sharedInstance().requestRecordPermission { granted in }
    }
  }

  private func requestBluetoothPermission() {
    centralManager = CBCentralManager(delegate: nil, queue: nil)
  }

  private func requestLocationPermission() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.requestAlwaysAuthorization()
  }
}

extension AppDelegate: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      print("Location authorization status: Not determined")
      break
    case .restricted, .denied:
      print("Location authorization status: Restricted or denied")
      break
    case .authorizedWhenInUse, .authorizedAlways:
      print("Location authorization status: Authorized")
      break
    @unknown default:
      print("Location authorization status: Unknown")
      break
    }
  }
}
