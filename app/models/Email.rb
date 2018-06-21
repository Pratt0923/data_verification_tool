class Email < ActiveRecord::Base
  serialize :qa_list_data, Hash
  serialize :body, Array
  serialize :header, Array
  serialize :footer, Array
end
