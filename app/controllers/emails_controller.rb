require 'Email'
require 'roo'
require 'PG'
require 'uri'
require 'selenium-webdriver'

class EmailsController < ApplicationController
   skip_before_action :verify_authenticity_token

  def email_merge_variables_pick
    csv_text = File.read(params[:item].tempfile)
    @csv = CSV.parse(csv_text, :headers => true)
  end

  def emails
    email_count = 1
    versions_present = []
    pg_lines_used = []
    @programming_grid = PG.new("email")
    @new_qa_list = QA_LIST.new(@programming_grid)
    Dir["#{ENV["HOME"]}/Desktop/QA/*.eml"].each do |email|
      mail = Mail.read(email)

      @body, cust_number = Email.changes_to_body(mail)
      @from = mail.from.first
      @subject = mail.subject
      # @new_qa_list.merge_variables(@new_qa_list.programming_grid.qa_list, "MV 10 =", cust_number, @programming_grid.email_sheet)

      @new_qa_list.merge_variables(@programming_grid.email_sheet, "MV 10 =", cust_number, @programming_grid.email_sheet)
      @new_qa_list, qa_list = @new_qa_list.make_new_qa_list_and_clean
      # @footer, @header, @body = Email.pull_out_header_and_footer_from_email(@body)
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

      current_email.version = Email.compare_correct_row_with_mvs(params, current_email, @new_qa_list, @programming_grid)
      @all_versions = @programming_grid.make_versions_match_specific_format(params)
      versions_present.push(current_email.version)

      EmlToPdf.convert("#{email}", "#{ENV["HOME"]}/Desktop/QA/'#{email_count}'.pdf")

      session = GoogleDrive::Session.from_config("config.json")
      upload = session.upload_from_file("#{ENV["HOME"]}/Desktop/QA/#{email_count}.pdf", "#{current_email.subject}#{email_count}.pdf", convert:false)
      session.collection_by_title("Emails").add(upload)
      current_email.qa_list_data["image"] = upload.id

      email_count += 1

      # TODO: clean this up and make it into a method so you are not repeating
      b = 0
      body_hash = {}
      unless current_email.version == "single version"
        @programming_grid.find_with_single_version_or_not(body_hash, b, current_email, false, pg_lines_used)
      else
        @programming_grid.find_with_single_version_or_not(body_hash, b, current_email, true, pg_lines_used)
      end
      # this is all the lines that are used in the programming grid.
      pg_lines_used.uniq!
      # TODO: display all the lines that are NOT used in the programming grid.
      # can be: on a seperate page, on the same page. whatever.
      current_email.save!
    end
    @versions_not_preset = @programming_grid.check_if_versions_all_present(@all_versions, versions_present)
    @all_emails = Email.all
    @email = Email.first
  end

  def clear
    @all_emails = Email.all
    Email.delete_all
    redirect_to :root
  end

  def spellcheck
    misspellings = []
    @all_email = Email.all
    @email = Email.find(params[:id])
    Email.spellchecker(@email.body, misspellings)
    Email.spellchecker(@email.header, misspellings)
    Email.spellchecker(@email.footer, misspellings)
    @misspellings = misspellings.flatten!
  end

  def select
    @temp = "hello"
    @all_emails = Email.all
    @email = Email.find(params[:id])
  end

  def upload
  end
end
