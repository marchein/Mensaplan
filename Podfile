use_frameworks!

def shared_pods_all
  pod 'SDWebImage', '~> 5.0'
end

def shared_pods_ios
  pod 'WatchSync'
end

def shared_pods_tv
  pod 'SwiftyXMLParser', :git => 'https://github.com/yahoojapan/SwiftyXMLParser.git'
end
  
target 'Mensaplan' do
  platform :ios, '11.0'
  shared_pods_all
  shared_pods_ios
  shared_pods_tv
  pod 'Toast-Swift', '~> 5.0.0'
end

target 'Watchapp Extension' do
  platform :watchos, '4.0'
  shared_pods_all
  shared_pods_ios
end

#target 'Mensaplan TV' do
#  platform :tvos, '9.0'
#  shared_pods_all
#  shared_pods_tv
#end
