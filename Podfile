platform :ios, '17.0'
use_frameworks!

target 'dev-aasdf' do
  # Networking (optional - current implementation uses URLSession)
  # pod 'Alamofire', '~> 5.8'
  
  # Solana utilities (optional - for advanced features)
  # pod 'SolanaSwift', '~> 4.0'
  
  # Base58 encoding (optional - Phantom returns base58 signatures)
  # pod 'Base58Swift', '~> 2.1'
  
  # Crypto library for Phantom Wallet (XSalsa20-Poly1305)
  pod 'Sodium', '0.9.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
      # Fix for library distribution and search paths
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
