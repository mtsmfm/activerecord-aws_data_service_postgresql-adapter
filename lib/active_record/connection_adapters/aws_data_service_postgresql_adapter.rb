require 'active_record/connection_adapters/postgresql_adapter'

require 'active_record/connection_adapters/aws_data_service_postgresql/connection'

module ActiveRecord
  module ConnectionHandling
    def aws_data_service_postgresql_connection(config)
      ConnectionAdapters::AwsDataServicePostgresqlAdapter.new(
        ConnectionAdapters::AwsDataServicePostgresql::Connection.new(config), logger, nil, config
      )
    end
  end

  module ConnectionAdapters
    class AwsDataServicePostgresqlAdapter < PostgreSQLAdapter
      ADAPTER_NAME = 'AwsDataServicePostgresql'.freeze
    end
  end
end
