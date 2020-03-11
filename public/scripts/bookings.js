"use strict";

$(document).ready(start);
function start(){
    $(".ticket-card").click(ticket_selected);
}

function ticket_selected() {
    $(".ticket-selected").removeClass("ticket-selected");
    $(this).addClass("ticket-selected");

    var source = $(this).find(".source");
    var departureTime = source.find(".time").text();
    var departureLoc = source.find(".location").text();

    var destination = $(this).find(".destination");
    var arrivalTime = destination.find(".time").text();
    var arrivalLoc = destination.find(".location").text();

    var price = $(this).find(".price").text();

    // console.log(departureTime);
    // console.log(departureLoc);
    // console.log(arrivalTime);
    // console.log(arrivalLoc);
    // console.log(price);

    $("#summary_details").html(departureTime + " " + departureLoc + "<br/>" + arrivalTime + " " + arrivalLoc + "<br/>" + price);
}
