require 'Email'
require 'roo'
require 'PG'

class EmailsController < ApplicationController
   skip_before_action :verify_authenticity_token

  def email_merge_variables_pick
  end

  def emails
    @programming_grid = PG.new
    Dir["#{ENV["HOME"]}/Desktop/QA/*.eml"].each do |email|
      mail = Mail.read(email)
      @body = mail.parts[0].body.decoded.gsub(/(?:f|ht)tps?:\/[^\s]+/, '').gsub!(/\r/, '').gsub!(/\n/, ' ')
      @body = @body.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      @from = mail.from.first
      @subject = mail.subject
      cust_number = /(\d+)(?!.*\d)/.match(@body)
      @merge_variable = @programming_grid.merge_variables(@programming_grid.email_sheet, "MV 10 =", cust_number)
      @new_qa_list = QA_LIST.new(@programming_grid)
      headers, data = @new_qa_list.sanitize_qa_list
      data.reject! { |c| c.empty? }
      qa_list = Hash[headers.zip(data)]
      current_email = Email.create(
        subject: @subject,
        from: @from,
        body: @body,
        cust_num: cust_number.captures.first,
        qa_list_data: qa_list,
        version: "could not display version"
      )
      current_email.version = compare_correct_row_with_mvs(params, current_email)
        if @programming_grid.find_line(@programming_grid, current_email.from, current_email) != nil
          current_email.qa_list_data["from"] = @programming_grid.find_line(@programming_grid, current_email.from, current_email).flatten!
        end
        if @programming_grid.find_line(@programming_grid, current_email.subject, current_email) != nil
          current_email.qa_list_data["subject"] = @programming_grid.find_line(@programming_grid, current_email.subject, current_email).flatten!
        end
      current_email.save!
    end
    @all_emails = Email.all
  end

  def clear
    Email.delete_all
    redirect_to :root
  end

  def compare_correct_row_with_mvs(params, current_email)
    params = @new_qa_list.clean_parameters(params)
    pg_versions = []
    params.each_pair do |key, value|
      if key != "Version"
          pg_versions.push(current_email.qa_list_data[key])
      end
    end
    h = Hash.new
    params.values.transpose.each do |e|
      key = e.shift
      value = e
      if h[key]
        h[key].push(value)
        h[key].flatten!
      else
        h[key] = value
      end
    end
    h.each_pair do |key, value|
      correct_mvs_found = value
        value.each do |val|
          if val.to_s.include?("-")
            if (val.split("-").first.to_i..val.split("-").last.to_i).include?(pg_versions.first.to_i)
              correct_mvs_found -= [val]
            end
          end
          if pg_versions.include?(val)
            correct_mvs_found -= [val]
          end
        end

      if correct_mvs_found.empty?
        return key
      end
    end
  end

end
