platform :ios, '17.0'
use_frameworks!

target 'dev-aasdf' do
  # Networking (optional - current implementation uses URLSession)
  # pod 'Alamofire', '~> 5.8'
  
  # Solana utilities (optional - for advanced features)
  # pod 'SolanaSwift', '~> 4.0'
  
  # Base58 encoding (optional - Phantom returns base58 signatures)
  # pod 'Base58Swift', '~> 2.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
