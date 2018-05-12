function get_text_to_replace_p_tag(i, pg_section, pg_part) {
  var array = [];
  //split text
  var split_text = $(pg_section)[i].outerText.split('');

  // put all text in array before query
  if(pg_part != null) {
    array.push("<p>");
    for (i = 0; i < pg_part.index; i++) {
      array.push(split_text[i]);
    };
    //split query and get length
    var split_query_length = pg_part[0].split('').length;
    var starting_point = pg_part.index + split_query_length;

    array.push("<span class='highlight'>");
    array.push(pg_part[0]);
    array.push("</span>");

    //put all text in array after query
    for (i = 0; i <= split_text.length; i++) {
      if (i >= starting_point) {
        array.push(split_text[i]);
      };
    };
    array.push("</p>");
    return Array.prototype.concat.apply([], array).join("");
  };
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
}

//making the padding for the pg and the email the same
var emails = document.getElementsByClassName("email");
var rows = document.getElementsByClassName("pg");
for (i = 0; i < emails.length; i++) {
  (emails[i].style.height) = (rows[i].clientHeight.toString() + "px");
  var from_sanitized = $(".from")[i].value.split('');
  var subject_sanitized = $(".subject")[i].value.split('');
  var body_sanitized = $(".body")[i].value.split('');

// must make this work for when there is no matching from/subject/or body
if ($('.pgfrom')[i].outerText != "") {
  $('.pgfrom').eq(i).html(sanitize_email_sections(from_sanitized, ".from", ".pgfrom", i));
};
  $('.pgsubject').eq(i).html(sanitize_email_sections(subject_sanitized, ".subject", ".pgsubject", i));
  $('.pgbody').eq(i).html(sanitize_email_sections(body_sanitized, ".body", ".pgbody", i));
};
