$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "meta_field/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "meta_field"
  s.version     = MetaField::VERSION
  s.authors     = ["Yuichi Takeuchi"]
  s.email       = ["uzuki05@takeyu-web.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of MetaField."
  s.description = "TODO: Description of MetaField."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
end
