# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Momentify' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Momentify config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'

pod 'Firebase'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Core'
pod 'Firebase/Storage'
pod 'SVProgressHUD'
pod 'ChameleonFramework'
pod 'FacebookCore'
pod 'FacebookLogin'
pod 'FacebookShare'
pod 'FBSDKLoginKit'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
