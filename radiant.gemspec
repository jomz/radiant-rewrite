$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "radiant/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "radiant"
  spec.version     = Radiant::VERSION
  spec.authors     = ["Benny Degezelle"]
  spec.email       = ["hi@monkeypatch.be"]
  spec.homepage    = "http://radiantcms.org"
  spec.summary     = "Radiant is a simple and powerful publishing system designed for small teams.
It is built with Rails and is similar to Textpattern or MovableType, but is
a general purpose content managment system--not merely a blogging engine."
  spec.description = "Probably the best CMS in the world"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.2"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec", "~> 3.8.0"
  spec.add_development_dependency "rspec-rails", "~> 3.8.2"
end
