begin
  require 'rspec/core'
  require 'rspec/core/rake_task'

  task :ci => [
    'cruise_spec'
  ]

  desc "Run all specs in spec directory (excluding plugin specs)"
  RSpec::Core::RakeTask.new(:cruise_spec) do |t|
    out = File.join(File.expand_path(File.dirname(__FILE__)), "..","test_reports/Rspec.html")
    t.rspec_opts = ["--format", "html", "-o", out, "--format", "documentation", "--color", "--tty"]
    excluded_paths = ['bundle', 'spec', 'config/boot.rb', '/var/', '/usr']
    t.pattern = "spec/**/*_spec.rb"
  end
rescue LoadError => e
end
