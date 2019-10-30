require 'aws-sdk-rdsdataservice'

module ActiveRecord
  module ConnectionAdapters
    module AwsDataServicePostgresql
      class Result
        include Enumerable

        def initialize(result)
          @result = result
        end

        def each(as: :hash)
          return unless @result.records || @result.generated_fields
          raise if @result.records && @result.generated_fields

          @result.lazy.flat_map {|page|
            (page.records || [page.generated_fields]).map {|row|
              row.map {|c| c.is_null ? nil : c.values.compact.first }
            }
          }.each do |row|
            if as == :array
              yield row
            else
              yield fields.zip(row).to_h
            end
          end
        end

        def clear
          @result.records = nil
        end

        # https://github.com/ged/ruby-pg/blob/cfb90ef5168ec5c8091e258a19f32483d0b179f3/ext/pg_result.c#L579
        def nfields
          fields.length
        end

        # https://github.com/ged/ruby-pg/blob/cfb90ef5168ec5c8091e258a19f32483d0b179f3/ext/pg_result.c#L732
        def ftype(i)
        end

        # https://github.com/ged/ruby-pg/blob/cfb90ef5168ec5c8091e258a19f32483d0b179f3/ext/pg_result.c#L1031
        def values
          to_enum(:each, as: :array).to_a
        end

        private

        def fields
          @fields ||= @result.column_metadata ? @result.column_metadata.map(&:label) : []
        end
      end

      class Connection
        attr_accessor :type_map_for_results, :type_map_for_queries

        def initialize(secret_arn:, resource_arn:, database:, **config)
          @client = ::Aws::RDSDataService::Client.new
          @secret_arn = secret_arn
          @resource_arn = resource_arn
          @database = database
        end

        def async_exec(sql)
          _query(sql)
        end

        def exec_params(sql, *params)
          _query(sql)
        end

        def escape(str)
          PG::Connection.escape(str)
        end

        def query(sql)
          _query(sql)
        end

        def server_version
          _query("select current_setting('server_version_num');").first['current_setting'].to_i
        end

        def close
        end

        private

        attr_reader :client, :secret_arn, :resource_arn, :database

        def _query(sql, **options)
          @last_result = client.execute_statement(
            secret_arn: secret_arn, resource_arn: resource_arn, sql: sql, database: database, include_result_metadata: true, transaction_id: @current_transaction&.transaction_id
          )
          Result.new(@last_result)
        rescue Aws::RDSDataService::Errors::BadRequestException => error
          if error.message.include?("No database selected")
            raise ActiveRecord::NoDatabaseError
          else
            raise
          end
        end
      end
    end
  end
end
