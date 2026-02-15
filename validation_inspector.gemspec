# frozen_string_literal: true

require_relative "lib/validation_inspector/version"

Gem::Specification.new do |spec|
  spec.name = "validation_inspector"
  spec.version = ValidationInspector::VERSION
  spec.authors = ["tenmihi"]
  spec.email = ["tenmihi@gmail.com"]

  spec.summary = "List ActiveModel validation callbacks with conditions."
  spec.description = "ValidationInspector lists ActiveModel validation callbacks and their conditions (if/unless), including attributes and custom/proc validators." # rubocop:disable Layout/LineLength
  spec.homepage = "https://github.com/tenmihi/validation_inspector"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["source_code_uri"] = "https://github.com/tenmihi/validation_inspector"
  spec.metadata["changelog_uri"] = "https://github.com/tenmihi/validation_inspector/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rubocop.yml])
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
