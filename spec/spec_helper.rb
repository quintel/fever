require 'bundler/setup'
require 'support/coverage'
require 'fever'

begin
  require 'pry'
rescue LoadError
  puts 'Pry not installed; binding.pry will be unavailable.'
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Enable auto-focus only when running locally
  config.filter_run_including(focus: !ENV['CI'])
  config.run_all_when_everything_filtered = true
end
