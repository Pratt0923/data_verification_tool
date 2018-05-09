function get_text_to_replace_p_tag(i, pg_section, pg_part) {
  var array = [];
  //split text
  var split_text = $(pg_section)[i].outerText.split('');

  // put all text in array before query
  for (i = 0; i < pg_part.index; i++) {
    array.push(split_text[i]);
  };
  //split query and get length
  var split_query_length = pg_part[0].split('').length;
  var starting_point = pg_part.index + split_query_length;

  array.push("<style class='highlight'>");
  array.push(pg_part[0]);
  array.push("</style>");
  //need to put style string in here and then query and then end style string, all split
  //put all text in array after query
  for (i = 0; i > starting_point; i++) {
    array.push(split_text[i]);
  };
  return Array.prototype.concat.apply([], array).join("");
};

//adding slashes to make the match work
function sanitize_email_sections(part, section, pgsection, i) {
  if($(section)[0].value.match(/[?]/) != null) {
    part.splice($(section)[0].value.match(/[?]/).index, 0, "\\");
  };
  part = part.join("");

// performting the match
  var pg_take_out = $(pgsection)[i].outerText.match(part);
  return get_text_to_replace_p_tag(i, pgsection, pg_take_out);
  // return pg_take_out;
}

//making the padding for the pg and the email the same
var i;
var emails = document.getElementsByClassName("email");
var rows = document.getElementsByClassName("pg");
for (i = 0; i < emails.length; i++) {
  (emails[i].style.height) = (rows[i].clientHeight.toString() + "px");
  var from_sanitized = $(".from")[i].value.split('');
  var subject_sanitized = $(".subject")[i].value.split('');
  var body_sanitized = $(".body")[i].value.split('');
  var a = sanitize_email_sections(from_sanitized, ".from", ".pgfrom", i);
  var b = sanitize_email_sections(subject_sanitized, ".subject", ".pgsubject", i);
  var c = sanitize_email_sections(body_sanitized, ".body", ".pgbody", i);
};
