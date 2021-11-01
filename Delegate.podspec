Pod::Spec.new do |spec|

  spec.name         = "Delegate"
  spec.version      = "1.1.0"
  spec.summary      = "A meta library to provide a better `Delegate` pattern."

  spec.description  = <<-DESC
                    A meta library to provide a better `Delegate` pattern. 
                    This provides you another way to use protocol-delegate pattern with ease.
                   DESC

  spec.homepage     = "https://github.com/onevcat/Delegate"
  spec.license      = "MIT"

  spec.ios.deployment_target = "9.0"
  spec.osx.deployment_target = "10.12"
  spec.watchos.deployment_target = "2.0"
  spec.tvos.deployment_target = "9.0"

  spec.author        = { "Wei Wang" => "onevcat@gmail.com" }
  spec.source        = { :git => "https://github.com/onevcat/Delegate.git", :tag => "#{spec.version}" }

  spec.swift_versions = ["5.2", "5.3", "5.4", "5.5"]

  spec.source_files  = "Sources/Delegate"
end
