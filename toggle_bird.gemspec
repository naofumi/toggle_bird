# frozen_string_literal: true

require_relative "lib/toggle_bird/version"

Gem::Specification.new do |spec|
  spec.name = "toggle_bird"
  spec.version = ToggleBird::VERSION
  spec.authors = ["Naofumi Kagami"]
  spec.email = ["naofumi@mac.com"]

  spec.summary = "A simple but flexible Feature Toggle/Flag manager with usage examples"
  spec.description = "ToggleBird is a Feature Toggle/Flag manager in 50 lines of code and has examples of how to use it in your Rails application."
  spec.homepage = "https://github.com/naofumi/toggle_bird"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/naofumi/toggle_bird"
  spec.metadata["changelog_uri"] = "https://github.com/naofumi/toggle_bird/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
