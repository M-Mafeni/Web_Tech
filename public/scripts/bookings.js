"use strict";

$(document).ready(start);
function start(){
    $(".ticket-card").click(ticket_selected);
}

function ticket_selected() {
    $(".ticket-selected").removeClass("ticket-selected");
    $(this).addClass("ticket-selected");
    
    var source = $(this).find(".source").text();
    var destination = $(this).find(".destination").text();

    console.log(source);
}
