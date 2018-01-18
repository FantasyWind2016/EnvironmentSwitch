#
# Be sure to run `pod lib lint EnvironmentSwitch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EnvironmentSwitch'
  s.version          = '0.1.0'
  s.summary          = 'Easy to switch server environment.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
可以简便地切换环境参数，支持以下功能：
1. 切换不同的服务端环境；
2. 支持增加自定义参数；
                       DESC

  s.homepage         = 'https://github.com/FantasyWind2016/EnvironmentSwitch'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '季风' => 'jihq@servyou.com.cn' }
  s.source           = { :git => 'https://github.com/FantasyWind2016/EnvironmentSwitch.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'EnvironmentSwitch/Classes/**/*'
  
  # s.resource_bundles = {
  #   'EnvironmentSwitch' => ['EnvironmentSwitch/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
