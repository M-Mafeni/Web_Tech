"use strict";

$(document).ready(start);

function start() {
    $("div.ticket-card").click(selected);
    var now = new Date();

    var day = ("0" + now.getDate()).slice(-2);
    var month = ("0" + (now.getMonth() + 1)).slice(-2);

    var today = now.getFullYear()+"-"+(month)+"-"+(day) ;
    $('#outbound_date').val(today);
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