Pod::Spec.new do |s|
  s.name         = "ContactsPicker"
  s.version      = "0.0.1"
  s.summary      = "Library for easy contacts accesss supporting >= iOS8."

  s.homepage     = "https://github.com/kunai-consulting/ContactsPicker"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Piotr Zmudzinski" => "ptr.zmudzinski@gmail.com" }
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/kunai-consulting/ContactsPicker.git", :branch => "master", :tag => "0.0.1" }

  s.source_files  = "ContactsPicker/**/*.{swift}", "ContactsPicker"
  s.exclude_files = "Classes/Exclude"

  s.frameworks = "Contacts", "AddressBook"
end