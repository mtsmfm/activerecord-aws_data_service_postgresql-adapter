require 'aws-sdk-rdsdataservice'

module ActiveRecord
  module ConnectionAdapters
    module AwsDataServicePostgresql
      class Connection
        def initialize(secret_arn:, resource_arn:, database:, **config)
          @secret_arn = secret_arn
          @resource_arn = resource_arn
          @database = database
        end
      end
    end
  end
end
