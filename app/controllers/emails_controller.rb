require 'Email'
require 'roo'
require 'PG'

class EmailsController < ApplicationController
  def main
  end

  def email_merge_variables_pick
    @programming_grid = PG.new
    @merge_variable = @programming_grid.merge_variables(@programming_grid.email_sheet, "MV 10 =", false)
    @merge_variable = sanitize_mv_list(@merge_variable)
    @merge_variable = [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10],[11, 12, 13, 14, 15]]
  end

  def emails
    Dir["#{ENV["HOME"]}/Desktop/QA/*.eml"].each do |email|
      mail = Mail.read(email)
      @body = mail.parts[0].body.decoded.gsub(/(?:f|ht)tps?:\/[^\s]+/, '').gsub!(/\r/, '').gsub!(/\n/, ' ')
      @body = @body.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      @from = mail.from.first
      @subject = mail.subject
      cust_number = /(\d+)(?!.*\d)/.match(@body)

      #------------------------------------ THERE MUST BE A WAY TO FIX THIS
      @programming_grid = PG.new
      @merge_variable = @programming_grid.merge_variables(@programming_grid.email_sheet, "MV 10 =", cust_number)
      #------------------------------------ THERE MUST BE A WAY TO FIX THIS
      headers, data = sanitize_qa_list(@programming_grid.qa_list_headers, @programming_grid.correct_row)

      Email.create(
        subject: @subject,
        from: @from,
        body: @body,
        cust_num: cust_number.captures.first,
        correct_row: data,
        qa_list_headers: headers
      )
    end
    @all_emails = Email.all
  end

  def clear
    Email.delete_all
    redirect_to :root
  end


  def sanitize_mv_list(mv)
    mv = mv.transpose.map { |x, *y| [x, y] }.to_h
    mv.each do |k, v|
      if v.uniq.first.nil?
        mv.delete(k)
      end
    end
    mv = mv.to_a
    mv.map { |array| array.flatten! }
    return mv
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
      qa_row.each do |item|
        if mv_keep.include?(item) && !qa_data[qa_row.index(item)].nil?
          data.push(qa_data[qa_row.index(item)])
          headers.push(item)
        end
      end
      return headers, data
    end
end
