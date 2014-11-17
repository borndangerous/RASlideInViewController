Pod::Spec.new do |s|
  s.name         = "StackViewController"
  s.version      = "1.0"
  s.summary      = "StackViewController has an transition effect expressing the depth, and you can dismiss it by draging"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.homepage     = "https://github.com/borndangerous/StackViewController"
  s.author       = { "ra1028" => "r.fe51028.r@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/borndangerous/StackViewController.git", :tag => "1.0" }
  s.requires_arc = true
  s.source_files = 'StackViewController/*.{h,m}'
end