"use strict";

$(document).ready(start);

function start(){
    $("#outbound div.ticket-card").click(outbound_selected);
    $("#inbound div.ticket-card").click(inbound_selected);
    $(".fa-angle-double-down").click(closeSummary);
    $(".fa-angle-double-up").click(showSummary);
    $(".continue-mobile").click(confirmBooking);

    $(window).scroll(fixSummary);
}

function inbound_selected(){
    var oldTotalPrice = Number($("#summary_price_mobile_final").text().substring(1));
    var oldTicketPrice = Number($(".d_ticket-selected .price").text().substring(1));

    $(".d_ticket-selected").removeClass("d_ticket-selected");
    $(this).addClass("d_ticket-selected");

    $(".summary_inbound").css("display", "inline-block");


    var source = $(this).find(".source");
    var departureDate = source.find(".date").text();
    var departureTime = source.find(".time").text();
    var departureLoc = source.find(".location").text();

    var destination = $(this).find(".destination");
    var arrivalDate = destination.find(".date").text();
    var arrivalTime = destination.find(".time").text();
    var arrivalLoc = destination.find(".location").text();

    var price = $(this).find(".price").text();
    var in_id = $(this).find(".ticket_id").text();

    $("#mobile_summary").show();
    $("#summary-title-mobile").text("Summary");
    $("#d_summary_price_mobile").text(price);
    $("#d_mobile_summary .departureDate").text(departureDate);
    $("#d_mobile_summary .departureTime").text(departureTime);
    $("#d_mobile_summary .departureLocation").text(departureLoc);
    $("#d_mobile_summary .arrivalDate").text(arrivalDate);
    $("#d_mobile_summary .arrivalTime").text(arrivalTime);
    $("#d_mobile_summary .arrivalLocation").text(arrivalLoc);

    let priceNum = Number(price.substring(1));
    if (oldTotalPrice == 0) {
        $("#summary_price_mobile_final").text(price);
        $("#summary_price_final").text(price);
    }
    else {
        $("#summary_price_mobile_final").text("£" + (oldTotalPrice - oldTicketPrice + priceNum).toString());
        $("#summary_price_final").text("£" + (oldTotalPrice - oldTicketPrice + priceNum).toString());
    }


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

    // put it into the hidden form for submission - is there a better way?
    $('input[name="in_id"]').val(in_id);
    $('input[name="in_price"]').val(price);
    $('input[name="in_o_date"]').val(departureDate);
    $('input[name="in_o_time"]').val(departureTime);
    $('input[name="in_o_loc"]').val(departureLoc);
    $('input[name="in_d_date"]').val(arrivalDate);
    $('input[name="in_d_time"]').val(arrivalTime);
    $('input[name="in_d_loc"]').val(arrivalLoc);

    if ($("#summary_price").text().length > 0) showContinueButtons();

    // display arrows
    if ($(".fa-angle-double-down").hasClass("disable-fa")) $(".fa-angle-double-up").removeClass("disable-fa");
}

function outbound_selected() {
    var oldTotalPrice = Number($("#summary_price_mobile_final").text().substring(1));
    var oldTicketPrice = Number($(".ticket-selected .price").text().substring(1));

    $(".ticket-selected").removeClass("ticket-selected");
    $(this).addClass("ticket-selected");

    $(".summary_outbound").css("display", "inline-block");

    var source = $(this).find(".source");
    var departureDate = source.find(".date").text();
    var departureTime = source.find(".time").text();
    var departureLoc = source.find(".location").text();

    var destination = $(this).find(".destination");
    var arrivalDate = destination.find(".date").text();
    var arrivalTime = destination.find(".time").text();
    var arrivalLoc = destination.find(".location").text();

    var price = $(this).find(".price").text();
    var out_id = $(this).find(".ticket_id").text();

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

    let priceNum = Number(price.substring(1));
    if (oldTotalPrice == 0) {
        $("#summary_price_mobile_final").text(price);
        $("#summary_price_final").text(price);
    }
    else {
        $("#summary_price_mobile_final").text("£" + (oldTotalPrice - oldTicketPrice + priceNum).toString());
        $("#summary_price_final").text("£" + (oldTotalPrice - oldTicketPrice + priceNum).toString());
    }

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

    // put it into the hidden form for submission - is there a better way?
    $('input[name="out_id"]').val(out_id);
    $('input[name="out_price"]').val(price);
    $('input[name="out_o_date"]').val(departureDate);
    $('input[name="out_o_time"]').val(departureTime);
    $('input[name="out_o_loc"]').val(departureLoc);
    $('input[name="out_d_date"]').val(arrivalDate);
    $('input[name="out_d_time"]').val(arrivalTime);
    $('input[name="out_d_loc"]').val(arrivalLoc);

    if ($("#d_summary_price").text().length > 0) showContinueButtons();


    // display arrows
    if ($(".fa-angle-double-down").hasClass("disable-fa")) $(".fa-angle-double-up").removeClass("disable-fa");
}

function showContinueButtons() {
    // display continue buttons
    $(".no-continue").removeClass("no-continue");
}

function showSummary() {
    $("#mobile_summary").addClass("change_height_mobile");
    $("#d_mobile_summary").addClass("change_height_mobile");
    $(".fa-angle-double-up").addClass("disable-fa");
    $(".fa-angle-double-down").removeClass("disable-fa");
}

function closeSummary() {
    $("#mobile_summary").removeClass("change_height_mobile");
    $("#d_mobile_summary").removeClass("change_height_mobile");
    $(".fa-angle-double-down").addClass("disable-fa");
    $(".fa-angle-double-up").removeClass("disable-fa");
}

function fixSummary() {
    // var fromTop = $(window).scrollTop();
    // var summaryOffset = $("#summaryTop").position().top - 20;
    //
    // if (fromTop > summaryOffset) {
    //     $("#summary").addClass("summary_fixed");
    //
    // } else {
    //     $("#summary").removeClass("summary_fixed");
    // }
}

function confirmBooking() {
    $('#hidden-form').submit();
}
