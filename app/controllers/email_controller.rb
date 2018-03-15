
class EmailController < ApplicationController

  def index
    mail = Mail.read('/Users/apratt/Desktop/thing.eml')
      @body = mail.parts[0].body.decoded.gsub!(/(?:f|ht)tps?:\/[^\s]+/, '')
      @body.gsub!(/\r/, '')
      @body.gsub!(/\n/, '')
  end

  def emails
    mail = Mail.read('/Users/apratt/Desktop/thing.eml')
      @body = mail.parts[0].body.decoded.gsub!(/(?:f|ht)tps?:\/[^\s]+/, '')
      @body.gsub!(/\r/, '')
      @body.gsub!(/\n/, '')
  end
end
