$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ez-cache/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ez-cache"
  s.version     = EzCache::VERSION
  s.authors     = ["Steve Aquino"]
  s.email       = ["aquino.steve@gmail.com"]
  s.homepage    = "https://github.com/SteveAquino/ez-cache"
  s.summary     = "It's so cool"
  s.description = "Easily create ETag caches and expire them at will."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0.0.beta3", "< 5.1"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "pry"
end
