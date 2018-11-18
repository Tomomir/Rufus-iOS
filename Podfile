# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'News' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for News
  pod 'Firebase/Core'
  pod 'FirebaseUI/Auth'
  pod 'FirebaseUI/Google'
  pod 'Firebase/Database'
  pod 'GoogleSignIn'
  pod 'JGProgressHUD'
  pod 'NavigationDrawer'
  pod 'FBSDKLoginKit'
  pod 'DeepDiff'
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings.delete('CODE_SIGNING_ALLOWED')
              config.build_settings.delete('CODE_SIGNING_REQUIRED')
          end
      end
      installer.pods_project.build_configurations.each do |config|
          config.build_settings.delete('CODE_SIGNING_ALLOWED')
          config.build_settings.delete('CODE_SIGNING_REQUIRED')
      end
  end
end
