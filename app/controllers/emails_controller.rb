require 'Email'
require 'roo'
require 'PG'

class EmailsController < ApplicationController
   skip_before_action :verify_authenticity_token
  def main
  end

  def email_merge_variables_pick
    # @programming_grid = PG.new
    # @merge_variable = @programming_grid.merge_variables(@programming_grid.email_sheet, "MV 10 =", false)
    # @merge_variable = sanitize_mv_list(@merge_variable)
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
      headers, data = sanitize_qa_list(@programming_grid.qa_list_headers, @programming_grid.correct_row)
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
      unless find_line(@programming_grid, current_email.subject, current_email).nil?
          if find_line(@programming_grid, current_email.from, current_email) != nil
            current_email.qa_list_data["PG_MATCH"] = {
            "from"=> find_line(@programming_grid, current_email.from, current_email).flatten!
            }
          end
          if find_line(@programming_grid, current_email.subject, current_email) != nil
            current_email.qa_list_data["PG_MATCH"] = {
            "subject"=> find_line(@programming_grid, current_email.subject, current_email).flatten!
            }
          end
      end
      current_email.save!
    end

    @all_emails = Email.all
  end

  def clear
    Email.delete_all
    redirect_to :root
  end

  def sanitize_mv_list(mv)
    mv.first.map! do |cell|
      if cell.nil?
        cell = "blank"
      else
        cell = cell
      end
    end
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

  def compare_correct_row_with_mvs(params, current_email)
    params = clean_parameters(params)
    correct_data = []
    params.each_pair do |key, value|
      if key != "Version"
          correct_data.push(current_email.qa_list_data[key])
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
      value.each do |val|
        if val.to_s.include?("-")
          s = val.split("-").first.to_i
          e = val.split("-").last.to_i
          until s == e + 1
            value.push(s.to_s)
            s += 1
          end
          if value.include?(correct_data.first)
            @key = key
            return key
          end
        end
        if correct_data.include?(val)
          @key = key
          return key
        elsif (value - correct_data).empty?
          @key = key
          return @key
        end
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
