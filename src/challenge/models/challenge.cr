require "granite_orm/adapter/mysql"

class Challenge < Granite::ORM::Base
  adapter mysql

  # id : Int64 primary key is created auto.
  field title : String
  field details : String
  field posted_by : String
  timestamps
end
