require 'Email'
require 'roo'
require 'PG_import'

class EmailController < ApplicationController

  def index
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
      @correct_row = programming_grid.correct_row
      @qa_list_row = programming_grid.qa_list_headers

      # @qa_list_row, @correct_row = sanitize_qa_list
      # binding.pry

      # Hosptial is spelled wrong ?????????????

      Email.create(
        subject: @subject,
        from: @from,
        body: @body,
        cust_num: cust_number.captures.first,
        correct_row: @correct_row,
        qa_list_headers: @qa_list_row
      )
      @all_emails = Email.all
    end
  end

  def clear
    Email.delete_all
    redirect_to :emails
  end


  # def sanitize_qa_list
  #   mv_keep = [
  #     "CUST_NO",
  #     "FIRST_NAME",
  #     "LAST_NAME",
  #     "ADDR_LINE_1",
  #     "ADDR_LINE_2",
  #     "ADDR_LINE_3",
  #     "ADDR_LINE_4",
  #     "ADDR_LINE_5",
  #     "POSTAL_CODE",
  #     "MERGE_VAR_2",
  #     "MERGE_VAR_3",
  #     "MERGE_VAR_5",
  #     "MERGE_VAR_10",
  #     "MERGE_VAR_11",
  #     "MERGE_VAR_12",
  #     "MERGE_VAR_13",
  #     "MERGE_VAR_14",
  #     "MERGE_VAR_15"
  #   ]
  #   @qa_list_row.reject {
  #     |item| mv_keep.include?(item)
  #     @correct_row.delete_at(item.index(item))
  #   }
  #   return @qa_list_row, @correct_row
  # end
end
