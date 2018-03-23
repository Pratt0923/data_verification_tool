class Email < ActiveRecord::Base
  serialize :correct_row, Array
  serialize :qa_list_headers, Array
end
