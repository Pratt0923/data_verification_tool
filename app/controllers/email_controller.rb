require 'Email'
require 'roo'
require 'PG_import'

class EmailController < ApplicationController

  def main
  end

  def emails
    Dir["#{ENV["HOME"]}/Desktop/code/Ruby_automation/*.eml"].each do |email|
      mail = Mail.read(email)
      @body = mail.parts[0].body.decoded.gsub(/(?:f|ht)tps?:\/[^\s]+/, '').gsub!(/\r/, '').gsub!(/\n/, ' ')
      @body = @body.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      @from = mail.from.first
      @subject = mail.subject
      cust_number = /(\d+)(?!.*\d)/.match(@body)
      programming_grid = PG_import.new


      @email_merge_variable = programming_grid.merge_variables(programming_grid.email_sheet, "MV 10 =", cust_number)
      # @correct_row = programming_grid.correct_row
      # @qa_list_row = programming_grid.qa_list_headers

      headers, data = sanitize_qa_list(programming_grid.qa_list_headers, programming_grid.correct_row)
      # Hosptial is spelled wrong ?????????????

      Email.create(
        subject: @subject,
        from: @from,
        body: @body,
        cust_num: cust_number.captures.first,
        correct_row: data,
        qa_list_headers: headers
      )
      @all_emails = Email.all
    end
  end

  def clear
    Email.delete_all
    redirect_to :root
  end


  def sanitize_qa_list(qa_row, qa_data)
    mv_keep = [
      "CUST_NO",
      "FIRST_NAME",
      "LAST_NAME",
      "ADDR_LINE_1",
      "ADDR_LINE_2",
      "ADDR_LINE_3",
      "ADDR_LINE_4",
      "ADDR_LINE_5",
      "POSTAL_CODE",
      "MERGE_VAR_2",
      "MERGE_VAR_3",
      "MERGE_VAR_5",
      "MERGE_VAR_10",
      "MERGE_VAR_11",
      "MERGE_VAR_12",
      "MERGE_VAR_13",
      "MERGE_VAR_14",
      "MERGE_VAR_15"
    ]
    data = []
    headers = []
#I need to fix this part. its not working really
      qa_row.each do |item|
        if mv_keep.include?(item) && !qa_data[qa_row.index(item)].nil?
          data.push(qa_data[qa_row.index(item)])
          headers.push(item)
        end
      end
      return headers, data
    end
end
