class Email < ActiveRecord::Base
  serialize :qa_list_data, Hash
end
