#
# Be sure to run `pod lib lint CircularControl.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CircularControl'
  s.version          = '0.1.0'
  s.summary          = 'A customizable circular slider based on UIControl.'

  s.homepage         = 'https://github.com/Peyotle/CircularControl'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Oleg Chernyshenko' => 'peyot3d@gmail.com' }
  s.source           = { :git => 'https://github.com/Peyotle/CircularControl.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'CircularControl/Classes/**/*'

end
