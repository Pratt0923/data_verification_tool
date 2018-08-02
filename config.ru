# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'


EmlToPdf.configure do |config|
  config.from_label = "From =>"
  config.to_label = "To =>"
  config.cc_label = "Cc =>"
  config.date_label = "Date =>"
  config.date_format do |date|
    date.strftime("%Y")
  end
end

run Rails.application
