require "bundler/setup"
Bundler.require

ENV["DATABASE_URL"] = "aws-data-service-postgresql:///?secret_arn=arn:aws:secretsmanager:xxxxx:xxxxx:secret:xxxxx&resource_arn=arn:aws:rds:xxxxx:xxxxx:cluster:xxxxx"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
