use_frameworks!

def shared_pods_all
  pod 'SDWebImage', '~> 5.0'
  pod 'WatchSync'
end
  
target 'Mensaplan' do
  platform :ios, '11.0'
  shared_pods_all
  pod 'SwiftyXMLParser', :git => 'https://github.com/yahoojapan/SwiftyXMLParser.git'
  pod 'Toast-Swift', '~> 5.0.0'
end

target 'Watchapp Extension' do
  platform :watchos, '4.0'
  shared_pods_all
end
