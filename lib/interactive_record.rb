require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    #extract the table name
    def self.table_name
        self.name.to_s.downcase.pluralize #downcase and pluralize class name
    end
  
    #get the column names
    def self.column_names
        #define an array to store column names
        columns = []

        #extract name
        sql = <<-SQL
          PRAGMA table_info(#{table_name})
        SQL

        #execute the code
        DB[:conn].execute(sql).each do |col|
            columns << col["name"]
        end

        #return the column names
        columns.compact
    end

    #define initialize method
    def initialize(params={})
        params.each do |attr, value|
            self.send("#{attr}=", value)
        end
    end

    ##table_name_for_insert
    def table_name_for_insert
        self.class.table_name
    end

    #col_names_for_insert
    # do not include id column, it will be added by sql
    def col_names_for_insert
        #array for columns
        insert_columns = []

        #add columns except id
        self.class.column_names.each do |column|
        insert_columns << column unless column == "id"
        end

        #turn columns to comma-separated string
        insert_columns.join(", ")
    end

    #values_for_insert
    # return values for insert
    def values_for_insert
        values = []

        #call the attributes reader methods, add values to array
        self.class.column_names.each do |col|
            values << "'#{send(col)}'" unless send(col).nil?
        end

        #return the values
        values.join(", ")
    end

    # save method
    # save the new record to the database
    def save
        #sql query to insert data
        sql = <<-SQL
          INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
        SQL

        #execute
        DB[:conn].execute(sql)

        #assign the id attribute the id value from db
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    #.find_by_name
    def self.find_by_name(name)
        #query to select record that matches name
        sql = <<-SQL
          SELECT * FROM #{self.table_name} WHERE name = ?
        SQL

        #execute the query
        DB[:conn].execute(sql, name)
    end

    #.find_by
    def self.find_by(attr)
        #parse the value
        #sql expects values to have '' quotes around them
        parsed_value = attr.values.first.class == Fixnum ? attr.values.first : "'#{attr.values.first}'"

        sql = <<-SQL
          SELECT * FROM #{self.table_name} WHERE #{attr.keys.first} = #{parsed_value}
        SQL

        #execute the query
        DB[:conn].execute(sql)
    end
end