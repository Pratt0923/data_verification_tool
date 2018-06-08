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
      new_qa_list = QA_LIST.new(@programming_grid)
      headers, data = new_qa_list.sanitize_qa_list
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
      @version = compare_correct_row_with_mvs(params, current_email)
      current_email.version = @version
      # unless find_line(@programming_grid, current_email.from, current_email).nil?
        # ok so the subject works because it is the last one in the thing. the from needs to be in some loop by itself
        if find_line(@programming_grid, current_email.from, current_email) != nil
          current_email.qa_list_data["from"] = find_line(@programming_grid, current_email.from, current_email).flatten!
        end
        # end
        # unless find_line(@programming_grid, current_email.subject, current_email).nil?
        if find_line(@programming_grid, current_email.subject, current_email) != nil
          current_email.qa_list_data["subject"] = find_line(@programming_grid, current_email.subject, current_email).flatten!
        end
      # end
      current_email.save!
    end
    @all_emails = Email.all
  end

  def clear
    Email.delete_all
    redirect_to :root
  end

  def compare_correct_row_with_mvs(params, current_email)
    params = clean_parameters(params)
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
              # binding.pry
              # @key = key
              # return key
            end
          end
  #what I want to due here is get rid of each value every time it is correct and then at the end check if it is empty. if it is empty then that is the version.
          if pg_versions.include?(val)
            correct_mvs_found -= [val]
            # binding.pry
          end

          # if pg_versions.include?(val)
          #   binding.pry
          #   # @key = key
          #   # return key
          # elsif (value - pg_versions).empty?
          #   binding.pry
          #   @key = key
          #   return @key
          # end
        end

if correct_mvs_found.empty?
  return key
end
    end
  end

  def clean_parameters(params)
    if params[:Version] then params[:Version].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_2] then params[:MERGE_VAR_2].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_3] then params[:MERGE_VAR_3].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_5] then params[:MERGE_VAR_5].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_10] then params[:MERGE_VAR_10].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_11] then params[:MERGE_VAR_11].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_12] then params[:MERGE_VAR_12].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_13] then params[:MERGE_VAR_13].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_14] then params[:MERGE_VAR_14].reject! { |c| c.empty? } end
    params.reject! { |t| params[t].empty? }
    params.reject! { |t| (t == "utf8") || (t == "authenticity_token") || (t == "commit") || (t == "controller") || (t == "action")}
    return params
  end

  def find_line(programming_grid, to_find, email)
    found = []
    # for single MV to version list
    # programming_grid.email_sheet.sheet("8538- Content Marketing").each_row_streaming do |row|
    #for comma seperated MVs
    # programming_grid.email_sheet.sheet("Email ImpGrid_8501").each_row_streaming do |row|
    #for age range single MV
    programming_grid.email_sheet.sheet("8513-E-Mail Imp Grid").each_row_streaming do |row|
      row.each do |r|
        unless r.value.nil?
          # for single MV to version list
          # if ((r.value.downcase.split(' ').include?((email.version.downcase || "global"))) && (programming_grid.email_sheet.sheet("8538- Content Marketing").row(r.coordinate.row).include?(to_find)))
          #for comma seperated MV
          # if (((r.value.to_s.downcase.split(' ').include?((email.version.downcase || "global"))) || r.value.to_s.downcase.include?((email.version.downcase || "global"))) && (programming_grid.email_sheet.sheet("Email ImpGrid_8501").row(r.coordinate.row).include?(to_find)))
          # for age range

          if (((r.value.to_s.downcase.split(' ').include?((email.version.downcase || "global"))) || r.value.to_s.downcase.include?((email.version.downcase || "global"))) && (programming_grid.email_sheet.sheet("8513-E-Mail Imp Grid").row(r.coordinate.row).include?(to_find)))

           found.push(row)
           return found
          end
        end
      end
    end
  end
end
