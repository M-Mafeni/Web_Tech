"use strict";

$(document).ready(start);

function start() {
    $('input[name="out_id"]').val($(this).find(".ticket_id").text()[0]);
    $('input[name="in_id"]').val($(this).find(".ticket_id").text()[1]);
    $("#payment").change(showPayButton)
}

function showPayButton() {
    if ($("#payment").val() != "Select card") {
        $("#payButton").show();
    }
    else {
        $("#payButton").hide();
    }
}
