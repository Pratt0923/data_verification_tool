class QA_LIST
  attr_accessor :programming_grid, :qa_list_headers, :qa_list, :correct_row
  def initialize(programming_grid)
    @programming_grid = programming_grid
  end

  def sanitize_qa_list
    qa_row = self.qa_list_headers
    qa_data = self.correct_row
    mv_keep = [
      "CUST_NO",
      "FIRST_NAME",
      "LAST_NAME",
      "ADDR_LINE_1",
      "ADDR_LINE_2",
      "ADDR_LINE_3",
      "ADDR_LINE_4",
      "ADDR_LINE_5",
      "POSTAL_CODE",
      "MERGE_VAR_2",
      "MERGE_VAR_3",
      "MERGE_VAR_5",
      "MERGE_VAR_10",
      "MERGE_VAR_11",
      "MERGE_VAR_12",
      "MERGE_VAR_13",
      "MERGE_VAR_14",
      "MERGE_VAR_15"
    ]
    data = []
    headers = []
      qa_row.each do |item|
        if mv_keep.include?(item) && !qa_data[qa_row.index(item)].nil?
          data.push(qa_data[qa_row.index(item)])
          headers.push(item)
        end
      end
      return headers, data
  end

  def merge_variables(sheet, string_include, cust_number, email_sheet)
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
        if (sheet == email_sheet) && (@programming_grid.qa_list.row(current_row).include?(cust_number.captures.first))
          @correct_row = @programming_grid.qa_list.row(current_row)
          @qa_list_headers = @programming_grid.qa_list.row(1)
        end
      end
      current_row += 1
    end
    return all_merge_variables
  end

  def clean_parameters(params)
    if params[:Version] then params[:Version].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_2] then params[:MERGE_VAR_2].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_3] then params[:MERGE_VAR_3].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_5] then params[:MERGE_VAR_5].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_10] then params[:MERGE_VAR_10].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_11] then params[:MERGE_VAR_11].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_12] then params[:MERGE_VAR_12].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_13] then params[:MERGE_VAR_13].reject! { |c| c.empty? } end
    if params[:MERGE_VAR_14] then params[:MERGE_VAR_14].reject! { |c| c.empty? } end
    params.reject! { |t| params[t].empty? }
    params.reject! { |t| (t == "utf8") || (t == "authenticity_token") || (t == "commit") || (t == "controller") || (t == "action")}
    return params
  end

  def make_new_qa_list_and_clean
    headers, data = self.sanitize_qa_list
    data.reject! { |c| c.empty? }
    qa_list = Hash[headers.zip(data)]
    return self, qa_list
  end

  def check_for_single_version_before_version_match(params, current_email)
    if params["Version"].include?("One Version")
      return "single version"
    end
    params = self.clean_parameters(params)
    pg_versions = []
    params.each_pair do |key, value|

      if key != "Version"
          pg_versions.push(current_email.qa_list_data[key])
      end
    end
    return pg_versions
  end

end
