$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "meta_field/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "meta_field"
  s.version     = MetaField::VERSION
  s.authors     = ["Yuichi Takeuchi"]
  s.email       = ["uzuki05@takeyu-web.com"]
  s.homepage    = "http://takeyu-web.com/"
  s.summary     = "ActiveRecord meta_field for Rails 3"
  s.description = "ActiveRecord meta_field for Rails 3"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
end
