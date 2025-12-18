# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
use_frameworks!

target 'FireChat' do
  
  pod 'Alamofire', '~> 5.0.0-rc.2'
  pod 'DGActivityIndicatorView'
  pod 'FirebaseAuth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'IQKeyboardManagerSwift', '6.5.12'
  pod 'SDWebImage'
  pod 'SKPhotoBrowser'
  pod 'ZLPhotoBrowser'
  
  
  # ignore all warnings from all pods
  inhibit_all_warnings!
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
      target.build_configurations.each do |config|
        config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
        config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
        config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      end
      target.build_configurations.each do |config|
        xcconfig_relative_path = "Pods/Target Support Files/#{target.name}/#{target.name}.#{config.name}.xcconfig"
        file_path = Pathname.new(File.expand_path(xcconfig_relative_path))
        next unless File.file?(file_path)
        
        configuration = Xcodeproj::Config.new(file_path)
        next if configuration.attributes['LIBRARY_SEARCH_PATHS'].nil?
        
        configuration.attributes['LIBRARY_SEARCH_PATHS'].sub! 'DT_TOOLCHAIN_DIR', 'TOOLCHAIN_DIR'
        configuration.save_as(file_path)
      end
    end
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      #config.build_settings.delete('CODE_SIGNING_ALLOWED')
      #config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
  end
  
  #if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
  
end
