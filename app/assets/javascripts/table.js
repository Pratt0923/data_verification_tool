//adding slashes to make the match work
function sanitize_email_sections(part, section, pgsection, i) {
  if($(section)[0].value.match(/[?]/) != null) {
    part.splice($(section)[0].value.match(/[?]/).index, 0, "\\");
  };
  part = part.join("");

// performting the match
  var pg_take_out = $(pgsection)[i].innerHTML.match(part);
  return pg_take_out;
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
  sanitize_email_sections(from_sanitized, ".from", ".pgfrom", i);
  sanitize_email_sections(subject_sanitized, ".subject", ".pgsubject", i);
  sanitize_email_sections(body_sanitized, ".body", ".pgbody", i);
};
