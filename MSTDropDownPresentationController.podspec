Pod::Spec.new do |s|
  s.name             = "MSTDropDownPresentationController"
  s.version          = "0.2.0"
  s.summary          = "A Drop Down Presentation Controller like Tweetbot 3's Timeline/Lists switcher."
  s.description      = <<-DESC
                       A Drop Down Presentation Controller like Tweetbot 3's Timeline/Lists switcher.

                       * Enables beautiful drop down view controller presentation.
                       * Subclass of UIPresentationController. Easy to use, Highly compatibility with UIKit.
                       * Requires iOS 8 and later.
                       DESC
  s.homepage         = "https://github.com/masahikot/MSTDropDownPresentationController"
  s.license          = 'MIT'
  s.author           = { "Masahiko Tsujita" => "masahikot.uec@icloud.com" }
  s.source           = { :git => "https://github.com/masahikot/MSTDropDownPresentationController.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'MSTDropDownPresentationController' => ['Pod/Assets/*.png']
  }
  s.frameworks = 'UIKit'
end
