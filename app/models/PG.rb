require 'roo'

class PG
  attr_reader :qa_list, :correct_row, :email_sheet, :direct_mail_sheet, :qa_list_headers
  def initialize(item)
    if item == "email"
      begin
        @email_sheet = Roo::Spreadsheet.open("#{ENV["HOME"]}/Desktop/QA/Programming_Grid.xlsx")
      rescue
        @email_sheet = Roo::Spreadsheet.open("#{ENV["HOME"]}/Desktop/QA/Programming_Grid.xlsm")
      end
      @email_sheet.default_sheet = 'Merge Variables' #name of tab
      @qa_list = Roo::Spreadsheet.open("#{ENV["HOME"]}/Desktop/QA/QA.csv")
    end
    if item == "dm"
      @direct_mail_sheet = Roo::Spreadsheet.open("#{ENV["HOME"]}/Desktop/QA/Direct_Mail_Programming_Grid.xlsx")
      @direct_mail_sheet.default_sheet = 'Follow Up Mail_Imp_Grid' #name of tab
      @notepad = File.read("#{ENV["HOME"]}/Desktop/QA/notepad.txt")
    end
  end

  def merge_variables(sheet, string_include, cust_number)
    current_row = 0
    tab = []
    all_merge_variables = []
    until current_row == sheet.last_row do
      tab.push(sheet.row(current_row))
      if tab.flatten.include?(string_include)
        all_merge_variables.push(sheet.row(current_row))
        break if ((sheet.row(current_row).all? &:blank?) == true)
      end
      if cust_number
        if (sheet == @email_sheet) && (self.qa_list.row(current_row).include?(cust_number.captures.first))
          @correct_row = self.qa_list.row(current_row)
          @qa_list_headers = self.qa_list.row(1)
        end
      end
      current_row += 1
    end
    return all_merge_variables
  end

  def find_line(programming_grid, to_find, email, single)
    found = []
    # TODO: make it so the user inputs the tab so we dont have to do anything with the code
    # 8513-E-Mail Imp Grid -> older younger
    # E-Mail Imp Grid -> HCEA112
    programming_grid.email_sheet.sheet("E-Mail Imp Grid").each_row_streaming do |row|
      row.each do |r|
        unless r.value.nil? || (r.value.class == Integer)
          r.value.gsub!(/<(.*?)>/, "")
          unless single

            if (programming_grid.email_sheet.sheet("E-Mail Imp Grid").row(r.coordinate.row).compact.index{|s| s.to_s.downcase.include?(email.version.to_s.downcase) || s.to_s.downcase.include?("global")}) && r.value.include?(to_find)
             found.push(row)
             return found
            end
          else
            if r.value.include?(to_find)
             found.push(row)
             return found
            end
          end
        end
      end
    end
  end

end
