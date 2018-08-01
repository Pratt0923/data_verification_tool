require 'Email'
require 'roo'
require 'PG'
require 'uri'
require 'selenium-webdriver'

class EmailsController < ApplicationController
   skip_before_action :verify_authenticity_token

  def email_merge_variables_pick
  end

  def emails
    @programming_grid = PG.new("email")
    @new_qa_list = QA_LIST.new(@programming_grid)
    Dir["#{ENV["HOME"]}/Desktop/QA/*.eml"].each do |email|
      mail = Mail.read(email)
      @body, cust_number = Email.changes_to_body(mail)
      @from = mail.from.first
      @subject = mail.subject
      @new_qa_list.merge_variables(@programming_grid.email_sheet, "MV 10 =", cust_number, @programming_grid.email_sheet)
      @new_qa_list, qa_list = @new_qa_list.make_new_qa_list_and_clean
      @footer, @header, @body = Email.pull_out_header_and_footer_from_email(@body)
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
      body_hash = {}
      i = 0
      unless current_email.version == "single version"
        @programming_grid.find_with_single_version_or_not(body_hash, i, current_email, false)
      else
        @programming_grid.find_with_single_version_or_not(body_hash, i, current_email, true)
      end
      current_email.save!
    end
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
    @all_emails = Email.all
    @email = Email.find(params[:id])
  end

end
