class Email < ActiveRecord::Base
  serialize :qa_list_data, Hash
  serialize :body, Array
  serialize :header, Array
  serialize :footer, Array

  def self.pull_out_header_and_footer_from_email(body)
    index_header = body.index{|s| s.include?("browser")}
    index_footer = body.index{|s| s.include?("About this email")}
    footer = body.slice(index_footer..body.index(body.last))
    header = body.slice(0..index_header)
    body = body.slice((index_header + 1)..(index_footer-1))
    return footer, header, body
  end

  def self.compare_correct_row_with_mvs(params, current_email, qa_list, programming_grid)
    pg_versions = qa_list.check_for_single_version_before_version_match(params, current_email)
    h = programming_grid.make_versions_match_specific_format(params)
    h.each_pair do |key, value|
      correct_mvs_found = value
        value.each do |val|
          if val.to_s.include?("-")
            correct_mvs_found = programming_grid.pg_version_compare_vs_qa_list_version(correct_mvs_found, val, pg_versions.first.to_i, val.split("-").first.to_i..val.split("-").last.to_i)
          end
          if val.include?(",")
            e = val.split(",")
            e.each do |comma|
              correct_mvs_found = programming_grid.pg_version_compare_vs_qa_list_version(correct_mvs_found, val, comma, pg_versions)
            end
          end
          correct_mvs_found = programming_grid.pg_version_compare_vs_qa_list_version(correct_mvs_found, val, val, pg_versions)
        end
      if correct_mvs_found.empty?
        return key
      end
    end
    return "could not find version"
  end

  def self.changes_to_body(mail)
    body = mail.parts[0].body.decoded.gsub(/(?:f|ht)tps?:\/[^\s]+/, '').gsub(/\n/, ' ').gsub(/\w*(@healthgrades.com)/, "")
    body = body.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    cust_number = /(\d+)(?!.*\d)/.match(body)
    body = body.split("\r").map {|line|
      line.strip
    }
    body.keep_if {|line| !line.empty?}   #=> ["a", "e"]
    body = body.map {|l| l.split( ". " || "? " || "! " )}
    body.flatten!
    body = body.map {|l| l.strip}
    return body, cust_number
  end

end
