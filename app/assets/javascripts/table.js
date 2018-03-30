var toggle_visible = function() {
    if ($("input#thing").is(':checked')){
      $( "th:nth-of-type(" + (($(event.target).parent().index()) + 1 ) +  ")" ).toggle()
      $( "td:nth-of-type(" + (($(event.target).parent().index()) + 1 ) + ")" ).toggle()
    }
  };

toggle_visible();

$( "input[type=checkbox]" ).on( "click", toggle_visible );
