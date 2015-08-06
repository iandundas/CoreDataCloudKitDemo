# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!

def all
	pod 'RxSwift'
	pod 'RxCocoa'
end

def testing_pods
    # If you're using Xcode 6 / Swift 1.2
    pod 'Quick', '~> 0.3.0'
    pod 'Nimble', '~> 1.0.0'
end

target 'CoreDataCloudKit' do
	all
end

target 'CoreDataCloudKitTests' do
	testing_pods
	all
end




