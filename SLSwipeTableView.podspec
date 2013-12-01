Pod::Spec.new do |s|
  s.name         = "SLSwipeTableView"
  s.version      = "0.0.1"
  s.summary      = "The swipe table view done right."

  s.homepage     = "http://EXAMPLE/SLSwipeTableView"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "shuo li" => "shuoli84@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  s.platform     = :ios, '7.0'

  # s.source       = { :git => "http://EXAMPLE/SLSwipeTableView.git", :tag => "0.0.1" }
  s.source = { :git => "https://github.com/shuoli84/SLSwipeTableView.git" }

  s.source_files  = 'SLSwipeTableView/SLSwipeTableView.{h,m}'
  s.requires_arc = true
end
