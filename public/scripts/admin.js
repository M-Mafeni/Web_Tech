"use strict";

$(document).ready(start);

function start() {
    $("div.ticket-card").click(selected);
    // $('#filter_form').click(filterTicket);
    // var now = new Date();
    //
    // var day = ("0" + now.getDate()).slice(-2);
    // var month = ("0" + (now.getMonth() + 1)).slice(-2);
    //
    // var today = now.getFullYear()+"-"+(month)+"-"+(day) ;
    // $('#outbound_date').val(today);
}

function selected(){
    $(".ticket-selected").removeClass("ticket-selected");
    $(this).addClass("ticket-selected");
    // $('div.summary').text('Entered');
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

    //set summary details
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

    $("#mobile_summary").show();
    $("#summary-title-mobile").text("Summary");
    $("#d_summary_price_mobile").text(price);
    $("#d_mobile_summary .departureDate").text(departureDate);
    $("#d_mobile_summary .departureTime").text(departureTime);
    $("#d_mobile_summary .departureLocation").text(departureLoc);
    $("#d_mobile_summary .arrivalDate").text(arrivalDate);
    $("#d_mobile_summary .arrivalTime").text(arrivalTime);
    $("#d_mobile_summary .arrivalLocation").text(arrivalLoc);

    $(".mobile").show();

    showContinueButtons();
}

function showContinueButtons() {
    // display arrows
    if ($(".fa-angle-double-down").hasClass("disable-fa")) $(".fa-angle-double-up").removeClass("disable-fa");
}

function checkEqual(ticket,t1,t2){
    if(t1){
        if(t1 !== t2){
            $(ticket).hide();
        }
    }
}
function filterTicket(){
    var origin = $('#origin').val();
    var destination = $('#destination').val();
    var o_date = $('#outbound_date').val();
    if(o_date) o_date = newFormat().formatDate(o_date);
    var d_date = $('#inbound_date').val();
    if(d_date) d_date = newFormat().formatDate(d_date);
    var tickets = $("div.ticket-card").toArray();
    tickets.forEach((ticket, i) => {
        $(ticket).show();
        var source = $(ticket).find('div.ticket-content.source');
        var dest = $(ticket).find('div.ticket-content.destination');
        var t_origin = $(source).find('.location').text();
        var t_o_date = $(source).find('.date').text();
        var t_destination = $(dest).find('.location').text();
        var t_d_date = $(dest).find('.date').text();
        checkEqual(ticket,origin,t_origin);
        checkEqual(ticket,destination,t_destination);
        checkEqual(ticket,o_date,t_o_date);
        checkEqual(ticket,d_date,t_d_date);
    });

}
function deleteTicket() {
    var id = $(".ticket-selected").find('.ticket_id').text();
    //ajax for client side requests
    $.ajax({
        url: '/admin/tickets/'+id,
        type: "DELETE",
        success: function(result){
            window.location.href = result;
        },
        error:function(error){
            console.log(`Error ${error}`);
        }
    });
}

function updateTicket(){
    var id = $(".ticket-selected").find('.ticket_id').text();
    window.location.href = '/admin/tickets/'+id;
    // $.ajax({
    //     url: '/admin/tickets/'+id,
    //     type: "GET",
    //     success: function(result){
    //         // console.log(result);
    //         window.location.href = '/admin/tickets/'+id;
    //     },
    //     error:function(error){
    //         console.log(`Error ${error}`);
    //     }
    // })
}
