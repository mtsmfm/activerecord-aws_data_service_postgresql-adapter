RSpec.describe "AwsDataServicePostgresqlAdapter" do
  it "does something useful" do
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    begin
      ActiveRecord::Tasks::DatabaseTasks.create_current('default_env')
    rescue
    end

    ActiveRecord::Schema.define do
      create_table :posts, force: true do |t|
      end

      create_table :comments, force: true do |t|
        t.integer :post_id
      end
    end

    class Post < ActiveRecord::Base
      has_many :comments
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end
  end
end
