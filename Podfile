# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'
source 'https://cdn.cocoapods.org/'

# hide the missing localizability warning on the pods project
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = "YES"
    end
  end
end

target 'ZelloSDKExampleApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ZelloSDKExampleApp
  pod "ZelloSDK", "~> 2.0"

end

target 'SDKNotificationServiceExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SDKNotificationServiceExtension
  pod "ZelloSDK", "~> 2.0"

end

