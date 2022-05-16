Pod::Spec.new do |s|
  s.name     = 'BDScrollBar'
  s.version  = '0.0.3'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'A classic-style scroll bar.'
  s.homepage = 'https://github.com/viewDidAppear/BDScrollBar'
  s.author   = 'Benjamin Deckys'
  s.source   = { :git => 'https://github.com/viewDidAppear/BDScrollBar.git', :tag => s.version }
  s.platform = :ios, '15.0'
  s.source_files = 'BDScrollBar/**/*.{swift}'
end
