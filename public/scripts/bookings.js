"use strict";

$(document).ready(start);
function start(){
    $(".ticket-card").click(ticket_selected);
}

function ticket_selected() {
    $(".ticket-selected").removeClass("ticket-selected");
    $(this).addClass("ticket-selected");

    var source = $(this).find(".source");
    var departureDate = source.find(".date").text();
    var departureTime = source.find(".time").text();
    var departureLoc = source.find(".location").text();

    var destination = $(this).find(".destination");
    var arrivalDate = destination.find(".date").text();
    var arrivalTime = destination.find(".time").text();
    var arrivalLoc = destination.find(".location").text();

    var price = $(this).find(".price").text();

    // console.log(departureTime);
    // console.log(departureLoc);
    // console.log(arrivalTime);
    // console.log(arrivalLoc);
    // console.log(price);
    
    if ($(window).width() < 1500) {
        $("#summary_details_mobile").html(departureDate + "<br/>" + departureTime + " " + departureLoc + "<br/><br/>" + arrivalDate + "<br/>" + arrivalTime + " " + arrivalLoc);
        $("#summary_price_mobile").text(price);
        
    } else {
        // code for large viewports
        $("#summary_details").html(departureDate + "<br/>" + departureTime + " " + departureLoc + "<br/><br/>" + arrivalDate + "<br/>" + arrivalTime + " " + arrivalLoc);
        $("#summary_price").text(price);
    }


}

function showSummary(){
    console.log("clicked");
    $("#mobile_summary").show();
}

function closeSummary(){
    $("#mobile_summary").hide();
}