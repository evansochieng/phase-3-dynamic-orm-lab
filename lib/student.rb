require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
    #create attr_accessor macro for the column names
    self.column_names.each do |col|
        attr_accessor col.to_sym
    end
end
