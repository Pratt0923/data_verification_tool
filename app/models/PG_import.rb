require 'roo'

class PG_import
  attr_reader :qa_list, :correct_row, :email_sheet, :direct_mail_sheet, :qa_list_headers
  def initialize
    @email_sheet = Roo::Spreadsheet.open("/Users/apratt/Desktop/code/Ruby_automation/HCEC11308536_8537_8538\ Programming\ Grid.xlsx")
    @email_sheet.default_sheet = 'Merge Variables' #name of tab
    @direct_mail_sheet = Roo::Spreadsheet.open("/Users/apratt/Desktop/code/Ruby_automation/HCEW11000424_HCEW11000430_Programming\ Grid.xlsm")
    @direct_mail_sheet.default_sheet = 'Follow Up Mail_Imp_Grid' #name of tab
    @qa_list = Roo::Spreadsheet.open("/Users/apratt/Desktop/code/Ruby_automation/HCEC11308539_01_QA.csv")
  end

  def merge_variables(sheet, string_include, cust_number)
    current_row = 0
    tab = []
    all_merge_variables = []
    until current_row == sheet.last_row do #do something until the last row is hit
      tab.push(sheet.row(current_row))
      if tab.flatten.include?(string_include) #when we reach the versioning section do thi
        all_merge_variables.push(sheet.row(current_row))
        break if ((sheet.row(current_row).all? &:blank?) == true)
      end
      #only email
      if (sheet == @email_sheet) && (self.qa_list.row(current_row).include?(cust_number.captures.first))

        @correct_row = self.qa_list.row(current_row)
        @qa_list_headers = self.qa_list.row(1)
      end
      #end only email
      current_row += 1
    end
    return all_merge_variables
  end

  # def direct_mail_merge_variables
  #   current_row = 0
  #   tab = []
  #   directmail_merge_variables = []
  #   until current_row == @direct_mail_sheet.last_row do #do something until the last row is hit
  #     tab.push(@direct_mail_sheet.row(current_row))
  #     if tab.flatten.include?("Variable Position") #when we reach the versioning section do thi
  #       directmail_merge_variables.push(@direct_mail_sheet.row(current_row))
  #       break if ((@direct_mail_sheet.row(current_row).all? &:blank?) == true)
  #     end
  #     current_row += 1
  #   end
  #   return directmail_merge_variables
  # end
end
