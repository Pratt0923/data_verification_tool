class DirectMailsController < ApplicationController
  def index
  end

  def direct_mail
    programming_grid = PG.new
    direct_mail = programming_grid.merge_variables(programming_grid.direct_mail_sheet, "Variable Position", false)
    @direct_mail_merge_variable = direct_mail.transpose
    @direct_mail_merge_variable.map! { |column| ((column.drop(1).uniq.first.nil?) ? (column = nil) : column) }
    @direct_mail_merge_variable.compact!
  end
end
