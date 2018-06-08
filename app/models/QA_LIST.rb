class QA_LIST
  attr_accessor :programming_grid
  def initialize(programming_grid)
    @programming_grid = programming_grid
  end

  def sanitize_qa_list
    qa_row = @programming_grid.qa_list_headers
    qa_data = @programming_grid.correct_row
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

end
