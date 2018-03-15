
require 'Email'

class EmailController < ApplicationController

  def index
  end

  def emails
    mail = Mail.read('/Users/apratt/Desktop/thing.eml')
      @body = mail.parts[0].body.decoded.gsub!(/(?:f|ht)tps?:\/[^\s]+/, '')
      @body.gsub!(/\r/, '')
      @body.gsub!(/\n/, ' ')
      @from = mail.from.first
      @subject = mail.subject
  end
end
