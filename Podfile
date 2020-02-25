use_frameworks!
def shared_pods
  pod 'SDWebImage', '~> 5.0'
end
target 'Mensaplan' do
  platform :ios, '11.0'
  shared_pods
  pod 'Toast-Swift', '~> 5.0.0'
  pod 'SwiftyXMLParser', :git => 'https://github.com/yahoojapan/SwiftyXMLParser.git'
  pod 'WatchSync'
end

target 'Watchapp Extension' do
  platform :watchos, '4.0'
  shared_pods
  pod 'WatchSync'
end
