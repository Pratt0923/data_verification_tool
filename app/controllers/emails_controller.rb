require 'Email'
require 'roo'
require 'PG'
require 'uri'
require 'selenium-webdriver'




class EmailsController < ApplicationController
   skip_before_action :verify_authenticity_token

  def email_merge_variables_pick
    # TODO: make it so the users have a "readme" on the main page for anything that might be complicated like the "one version"
    # that is already there.
  end

  def emails
    @programming_grid = PG.new("email")
    Dir["#{ENV["HOME"]}/Desktop/QA/*.eml"].each do |email|
      mail = Mail.read(email)


      # TODO: get selenium to work inside the ruby program. it is currently not working for some reason
      # OR
      # TODO: record all of the links in an array somewhere.
      # TODO: compare those links to links in the programming grid
      # TODO: make sure the links correspond to the right thing (link and text is the same)
      # TODO: figure out a game plan if the links redirect to the same place, but appear different
      @body = mail.parts[0].body.decoded.gsub(/(?:f|ht)tps?:\/[^\s]+/, '').gsub(/\n/, ' ').gsub(/\w*(@healthgrades.com)/, "")
      @body = @body.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      cust_number = /(\d+)(?!.*\d)/.match(@body)
      @body = @body.split("\r").map {|line|
        line.strip
      }
      @body.keep_if {|line| !line.empty?}   #=> ["a", "e"]
      @body = @body.map {|l| l.split( ". " || "? " || "! " )}
      @body.flatten!
      @body = @body.map {|l| l.strip}
      @from = mail.from.first
      @subject = mail.subject
      @programming_grid.merge_variables(@programming_grid.email_sheet, "MV 10 =", cust_number)
      @new_qa_list = QA_LIST.new(@programming_grid)
      headers, data = @new_qa_list.sanitize_qa_list
      data.reject! { |c| c.empty? }
      qa_list = Hash[headers.zip(data)]
      pull_out_header_and_footer_from_email
      current_email = Email.create(
        subject: @subject,
        from: @from,
        header: @header,
        body: @body,
        footer: @footer,
        cust_num: cust_number.captures.first,
        qa_list_data: qa_list,
        version: "could not display version"
      )
      current_email.version = compare_correct_row_with_mvs(params, current_email)
      body_hash = {}
      i = 0
      unless current_email.version == "single version"
        find_with_single_version_or_not(body_hash, i, current_email, false)
      else
        find_with_single_version_or_not(body_hash, i, current_email, true)
      end
      # TODO: return something if we don't find the line in the grid. maybe the thing we were supposed to find?
      current_email.save!
    end
    @all_emails = Email.all
  end

  def clear
    # TODO: make it so it will tell you the emails are cleared
    # TODO: tell the user how many emails they have loaded in the DB so that they know if they need to clear it
    @all_emails = Email.all
    Email.delete_all
    redirect_to :root
  end

  def find_with_single_version_or_not(body_hash, i, email, single)
    unless @programming_grid.find_line(@programming_grid, email.from, email, single).nil?
      email.qa_list_data["from"] = @programming_grid.find_line(@programming_grid, email.from, email, single).flatten!
    end
    unless @programming_grid.find_line(@programming_grid, email.subject, email, single).nil?
      email.qa_list_data["subject"] = @programming_grid.find_line(@programming_grid, email.subject, email, single).flatten!
    end
# TODO: we need to do this for the footer and header as well

    email.body.each do |sentance|
      unless @programming_grid.find_line(@programming_grid, sentance, email, single).nil?
        body_hash[i] = @programming_grid.find_line(@programming_grid, sentance, email, single).flatten!
      else
        body_hash[i] = [Roo::Excelx::Cell::String.new("COULD NOT FIND:  '#{sentance}'", nil, nil, nil, nil)]
      end
      i += 1
    end
    email.qa_list_data["body"] = body_hash
  end

  def pull_out_header_and_footer_from_email
    index_header = @body.index{|s| s.include?("browser")}
    index_footer = @body.index{|s| s.include?("About this email")}
    @footer = @body.slice(index_footer..@body.index(@body.last))
    @header = @body.slice(0..index_header)
    @body = @body.slice((index_header + 1)..(index_footer-1))
  end

  def compare_correct_row_with_mvs(params, current_email)
    pg_versions = check_for_single_version_before_version_match(params, current_email)
    h = make_versions_match_specific_format(params)

    h.each_pair do |key, value|
      correct_mvs_found = value
        value.each do |val|
          if val.to_s.include?("-")
            if (val.split("-").first.to_i..val.split("-").last.to_i).include?(pg_versions.first.to_i)
              correct_mvs_found -= [val]
            end
          end
          # this will only happen if correct_mvs contains a comma
          if val.include?(",")
            e = val.split(",")
            # then if it does we will go through each comma one
            e.each do |comma|
              if pg_versions.include?(comma)
                correct_mvs_found -= [val]
              end
            end
          end
          # if it includes a , do something here
          if pg_versions.include?(val)
            correct_mvs_found -= [val]
          end
        end
      if correct_mvs_found.empty?
        return key
      end
    end
    return "could not find version"
  end



  def make_versions_match_specific_format(params)
    # currently the versions are in [version, version, version][MV, MV, MV][MV, MV, MV] Format.
    # this makes them into {version=[MV, MV]} format
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
    return h
  end

  def check_for_single_version_before_version_match(params, current_email)
    if params["Version"].include?("One Version")
      return "single version"
    end
    params = @new_qa_list.clean_parameters(params)
    pg_versions = []
    params.each_pair do |key, value|

      if key != "Version"
          pg_versions.push(current_email.qa_list_data[key])
      end
    end
    return pg_versions
  end

end
