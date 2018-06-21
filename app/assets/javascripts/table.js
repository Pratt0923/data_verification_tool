function get_text_to_replace_p_tag(i, pg_section, pg_part) {

  //split text
  if (pg_section == ".pgfrom" || pg_section == ".pgsubject") {
    var array = [];
    var split_text = $(pg_section)[i].outerText.split('');
    if(pg_part != null) {
      array.push("<p>");
      for (l = 0; l < pg_part.index; l++) {
        array.push(split_text[l]);
      };
      //split query and get length
      var split_query_length = pg_part[0].split('').length;
      var starting_point = pg_part.index + split_query_length;
      array.push("<span class='highlight'>");
      array.push(pg_part[0]);
      array.push("</span>");

      //put all text in array after query
      for (l = 0; l <= split_text.length; l++) {
        if (l >= starting_point) {
          array.push(split_text[l]);
        };
      };
      array.push("</p>");

      return Array.prototype.concat.apply([], array).join("");
    };
  };

// TODO: the last version is replacing the first version. I need to stop this somehow
  if (pg_section == ".pgbody" && pg_part != null){
    var array = [];
    var split_text = pg_part.input.split('');

    array.push("<p>");


    for (l = 0; l < pg_part.index; l++) {
      array.push(split_text[l]);
    };



    var split_query_length = pg_part[0].split('').length;
    var starting_point = pg_part.index + split_query_length;
    // TODO: it would be nice to also tell the user what lines the rows it finds are on
    array.push("<span class='highlight'>");
    array.push(pg_part[0]);
    array.push("</span>");


    for (l = 0; l <= split_text.length; l++) {
      if (l >= starting_point) {
        array.push(split_text[l]);
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

  if (section == ".from" || section == ".subject"){
    var pg_take_out = $(pgsection)[i].outerText.match(part);
    return get_text_to_replace_p_tag(i, pgsection, pg_take_out);
  }


  if (section == ".body") {
    for (m = 0; m < $(".email").eq(i).find(".body").length; m++) {
      // pull the text out of the email tabs
      part = $(".email").eq(i).find(".body").eq(m)[0].value
      var pg_take_out = $(".pg").eq(i).find(".part_body")[m].outerText.match(part);
      $(".pg").eq(i).find('.part_body').eq(m).html(get_text_to_replace_p_tag(i, pgsection, pg_take_out))
    };
  };
}

//making the padding for the pg and the email the same
var emails = document.getElementsByClassName("email");
var rows = document.getElementsByClassName("pg");
for (i = 0; i < emails.length; i++) {
  // TODO: make the emails and programming grid sections have the same height so that its easier to read.
  // (emails[i].style.height) = (rows[i].clientHeight.toString() + "px");
  var from_sanitized = $(".from")[i].value.split('');
  var subject_sanitized = $(".subject")[i].value.split('');
  var body_sanitized = $(".body")[i].value.split('');

// must make this work for when there is no matching from/subject/or body
if ($('.pgfrom')[i].outerText != "") {
  $('.pgfrom').eq(i).html(sanitize_email_sections(from_sanitized, ".from", ".pgfrom", i));
};
  $('.pgsubject').eq(i).html(sanitize_email_sections(subject_sanitized, ".subject", ".pgsubject", i));
    sanitize_email_sections(body_sanitized, ".body", ".pgbody", i)
};
