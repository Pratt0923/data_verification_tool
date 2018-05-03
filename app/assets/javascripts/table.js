// (document.getElementsByClassName("email")[0].style.height) = (document.getElementsByClassName("pg")[0].clientHeight.toString() + "px");
// console.log(document.getElementsByClassName("email")[0].style.height);
// console.log(document.getElementsByClassName("pg")[0].clientHeight.toString() + "px");
var i;
var emails = document.getElementsByClassName("email");
var rows = document.getElementsByClassName("pg");
for (i = 0; i < emails.length; i++) {
  (emails[i].style.height) = (rows[i].clientHeight.toString() + "px");
}
