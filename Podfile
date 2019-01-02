use_frameworks!

target 'HiveShared' do
	platform :ios, '12.0'
	pod 'Alamofire', '~> 4.7.3'
	
	target 'HiveIntents'
	target 'HiveWidget'
	target 'Hive' do
		pod 'HueKit', :git => 'https://github.com/MutatingFunk/huekit'
	end
end

target 'HiveSharedWatch' do
	platform :watchos, '5.0'
	pod 'Alamofire', '~> 4.7.3'
	
	target 'HiveIntentsWatch'
end
