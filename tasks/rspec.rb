begin
  require 'rspec/core'
  require 'rspec/core/rake_task'

  spec_prereq = :noop
  task :noop do
  end

  desc "Run all specs in spec directory (excluding plugin specs)"
  RSpec::Core::RakeTask.new(:spec => spec_prereq) do |t|
    t.rspec_opts = ["--format", "documentation"]
    t.pattern = "spec/**/*_spec.rb"
  end

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.extend Macros::Controller, :type => :controller
    config.extend Macros::System
  end

rescue LoadError => e
  p e
end
