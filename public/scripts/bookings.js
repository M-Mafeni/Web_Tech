"use strict";

$(document).ready(start);

function start(){
    $("#outbound div.ticket-card").click(ticket_selected);
    $("#inbound div.ticket-card").click(return_selected);
    $(window).scroll(fixSummary);
}
function return_selected(){
    $(".d_ticket-selected").removeClass("d_ticket-selected");
    $(this).addClass("d_ticket-selected");

    var source = $(this).find(".source");
    var departureDate = source.find(".date").text();
    var departureTime = source.find(".time").text();
    var departureLoc = source.find(".location").text();

    var destination = $(this).find(".destination");
    var arrivalDate = destination.find(".date").text();
    var arrivalTime = destination.find(".time").text();
    var arrivalLoc = destination.find(".location").text();

    var price = $(this).find(".price").text();

    $("#mobile_summary").show();
    $("#summary-title-mobile").text("Summary");
    $("#d_summary_price_mobile").text(price);
    $("#d_mobile_summary .departureDate").text(departureDate);
    $("#d_mobile_summary .departureTime").text(departureTime);
    $("#d_mobile_summary .departureLocation").text(departureLoc);
    $("#d_mobile_summary .arrivalDate").text(arrivalDate);
    $("#d_mobile_summary .arrivalTime").text(arrivalTime);
    $("#d_mobile_summary .arrivalLocation").text(arrivalLoc);

    // code for large viewports
    $("#d_unselected").remove();
    $("#d_summary_details").show();
    $("#d_summary_details").addClass("change_height");
    $("#d_summary_details .departureDate").text(departureDate);
    $("#d_summary_details .departureTime").text(departureTime);
    $("#d_summary_details .departureLocation").text(departureLoc);
    $("#d_summary_details .arrivalDate").text(arrivalDate);
    $("#d_summary_details .arrivalTime").text(arrivalTime);
    $("#d_summary_details .arrivalLocation").text(arrivalLoc);
    $("#d_summary_price").text(price);
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
    //mobile code
    $("#mobile_summary").show();
    $("#summary-title-mobile").text("Summary");
    $("#summary_price_mobile").text(price);
    $("#mobile_summary .departureDate").text(departureDate);
    $("#mobile_summary .departureTime").text(departureTime);
    $("#mobile_summary .departureLocation").text(departureLoc);
    $("#mobile_summary .arrivalDate").text(arrivalDate);
    $("#mobile_summary .arrivalTime").text(arrivalTime);
    $("#mobile_summary .arrivalLocation").text(arrivalLoc);

    // code for large viewports
    $("#o_unselected").remove();
    $("#summary_details").show();
    $("#summary_details").addClass("change_height");
    $("#summary_details .departureDate").text(departureDate);
    $("#summary_details .departureTime").text(departureTime);
    $("#summary_details .departureLocation").text(departureLoc);
    $("#summary_details .arrivalDate").text(arrivalDate);
    $("#summary_details .arrivalTime").text(arrivalTime);
    $("#summary_details .arrivalLocation").text(arrivalLoc);
    $("#summary_price").text(price);

    // display continue buttons
    $(".no-continue").removeClass("no-continue");

    // display arrows
    if ($(".fa-angle-double-down").hasClass("disable-fa")) $(".fa-angle-double-up").removeClass("disable-fa");
}

function showSummary(){
    $("#mobile_summary").addClass("change_height_mobile");
    $(".fa-angle-double-up").addClass("disable-fa");
    $(".fa-angle-double-down").removeClass("disable-fa");
}

function closeSummary(){
    $("#mobile_summary").removeClass("change_height_mobile");
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
