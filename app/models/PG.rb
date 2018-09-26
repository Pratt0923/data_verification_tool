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

# TODO: right now a comma will break the find_line and it will not find the line. It needs to be able to find lines
  def find_line(programming_grid, to_find, email, single, pg_lines_used)
    found = []
    # TODO: make it so the user inputs the tab so we dont have to do anything with the code
    # 8513-E-Mail Imp Grid -> older younger
    # E-Mail Imp Grid -> HCEA112
    programming_grid.email_sheet.sheet("Email").each_row_streaming do |row|
      row.each do |r|
        unless r.value.nil? || (r.value.class == Integer)
          r.value.gsub!(/<(.*?)>/, "")
          r.value.gsub!(/’+/, "")
          r.value.gsub!(/\s{2,20}/, " ")
          unless single

            if (programming_grid.email_sheet.sheet("Email").row(r.coordinate.row).compact.index{|s| s.to_s.downcase.include?(email.version.to_s.downcase) || s.to_s.downcase.include?("global")}) && r.value.include?(to_find)
             found.push(row)
             pg_lines_used.push(r.coordinate.row)
             return found
            end
          else
            if r.value.include?(to_find)
             found.push(row)
             pg_lines_used.push(r.coordinate.row)
             return found
            end
          end
        end
      end
    end
  end

  def make_versions_match_specific_format(params)
    params_duplicate = params
    params.delete("page")
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

  def pg_version_compare_vs_qa_list_version(programming_grid_mv, item, search, to_search)
    if (to_search).include?(search)
      programming_grid_mv -= [item]
    end
    return programming_grid_mv
  end

  def find_with_single_version_or_not(body_hash, i, email, single, pg_lines_used)
    unless self.find_line(self, email.from, email, single, pg_lines_used).nil?
      email.qa_list_data["from"] = self.find_line(self, email.from, email, single, pg_lines_used).flatten!
    end
    unless self.find_line(self, email.subject, email, single, pg_lines_used).nil?
      email.qa_list_data["subject"] = self.find_line(self, email.subject, email, single, pg_lines_used).flatten!
    end

  # TODO: we need to do this for the footer and header as well

    email.body.each do |sentance|
      unless self.find_line(self, sentance, email, single, pg_lines_used).nil?
        body_hash[i] = self.find_line(self, sentance, email, single, pg_lines_used).flatten!
      else
        body_hash[i] = [Roo::Excelx::Cell::String.new("<span class='red'>MISSING FROM PG</span>:  '#{sentance}'", nil, nil, nil, nil)]
      end
      i += 1
    end
    email.qa_list_data["body"] = body_hash
  end

  def check_if_versions_all_present(all, list_of_found_versions)
    list_of_found_versions.each do |version|
      all.delete(version)
    end
    return all
  end

end
