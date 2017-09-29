require "mysql"

DB.open "mysql://challenger:GanfG1do@localhost:3306/challenge_dev" do |db|

  puts "challenges:"
  db.query "select id, title, details, posted_by from challenges order by id asc" do |rs|
    puts "#{rs.column_name(0)} (#{rs.column_name(1)}) (#{rs.column_name(2)}) (#{rs.column_name(3)})"
    # => name (age)
    rs.each do
      puts "#{rs.read(Int64)} (#{rs.read(String)}) (#{rs.read(String)}) (#{rs.read(String)})"
      # => Sarah (33)
      # => John Doe (30)
    end
  end
end
