"use strict";

$(document).ready(start);

function start(){
    $(".ticket-card").click(ticket_selected);
    $(window).scroll(fixSummary);
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

    $("#summary-title-mobile").text("Summary");
    $("#summary_price_mobile").text(price);

    // code for large viewports
    $("#unselected").remove();
    $("#summary_details").show();
    $(".departureDate").text(departureDate);
    $(".departureTime").text(departureTime);
    $(".departureLocation").text(departureLoc);
    $(".arrivalDate").text(arrivalDate);
    $(".arrivalTime").text(arrivalTime);
    $(".arrivalLocation").text(arrivalLoc);
    $("#summary_price").text(price);

    // display continue buttons
    $(".no-continue").removeClass("no-continue");

    // display arrows
    if ($(".fa-angle-double-down").hasClass("disable-fa")) $(".fa-angle-double-up").removeClass("disable-fa");
}

function showSummary(){
    console.log("clicked");
    $("#mobile_summary").show();
    $(".fa-angle-double-up").addClass("disable-fa");
    $(".fa-angle-double-down").removeClass("disable-fa");
}

function closeSummary(){
    $("#mobile_summary").hide();
    $(".fa-angle-double-down").addClass("disable-fa");
    $(".fa-angle-double-up").removeClass("disable-fa");
}

function fixSummary() {
    var fromTop = $(window).scrollTop();
    var summaryOffset = $("#summaryTop").position().top - 20;

    if (fromTop > summaryOffset) {
        $("#summary").addClass("summary_fixed");

    } else {
        $("#summary").removeClass("summary_fixed");
    }
}
