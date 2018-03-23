class Emails < ActiveRecord::Migration[5.1]
  create_table :emails do |t|
      t.string :subject
      t.string :from
      t.string :body
      t.string :cust_num
      t.string :correct_row
      t.string :qa_list_headers
    end
end
