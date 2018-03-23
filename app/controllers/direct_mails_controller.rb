class DirectMailsController < ApplicationController
  def index
  end

  def direct_mail
    programming_grid = PG.new
    # @merge_variable = programming_grid.direct_mail_merge_variables
    @direct_mail_merge_variable = programming_grid.merge_variables(programming_grid.direct_mail_sheet, "Variable Position", 0)
  end
end
