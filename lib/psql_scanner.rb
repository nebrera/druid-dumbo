require 'pg'
require 'time'
require 'json'

module Druid
  class PsqlScanner
    def initialize(opts = {})
      @data_source = opts[:data_source] || ENV['DRUID_DATASOURCE'] || raise('Must pass a :data_source param')
      @host = opts[:host] || ENV['DRUID_PSQL_HOST'] || 'localhost'
      @user = opts[:user] || ENV['DRUID_PSQL_USER'] || 'druid'
      @password = opts[:password] || ENV['DRUID_PSQL_PASSWORD']
      @db_name = opts[:db] || ENV['DRUID_PSQL_DB'] || 'druid'
      @table_name = opts[:table] || ENV['DRUID_PSQL_TABLE'] || 'segments'

      @db = PG::Connection.new( dbname: @db_name, host: @host, user: @user, password: @password )
    end

    def scan
      ranges = []
      marker = ''

      puts 'Scanning psql...'
      @db.query("select payload from #{@table_name} where used = true").each do |row|
        descriptor = JSON.parse(row["payload"])
        if descriptor['dataSource'] == @data_source
          interval = descriptor['interval'].split('/')

          ranges.push({
            'start' => Time.parse(interval[0]).to_i,
            'end' => Time.parse(interval[1]).to_i,
            'created' => Time.parse(descriptor['version']).to_i
          })
        else
          puts "Skipping #{descriptor} because it does not match #{@data_source}"
        end
      end
      puts 'Scanning psql completed'
      ranges
    end

  end
end
