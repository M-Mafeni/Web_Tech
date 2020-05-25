"use strict";

var svgOnScreen = false;
var animated_rocket = new Image();
animated_rocket.src = "assets/sideways_rocket_animated.svg";

$(document).ready(start);

function start() {
    $(window).scroll(playSVG);
    setOutboundDate();
}

// set outbound date picker to today
function setOutboundDate() {
    var now = new Date();

    var day = ("0" + now.getDate()).slice(-2);
    var month = ("0" + (now.getMonth() + 1)).slice(-2);

    var today = now.getFullYear()+"-"+(month)+"-"+(day) ;
    $('#outbound_date').val(today);
}

// restarts the animated rocket svg when it comes on-screen
function playSVG() {
    let svg = $("#animated_rocket");
    let svgTop = svg.offset().top - $(window).scrollTop();
    let svgBottom = svgTop + svg.height();

    if (!svgOnScreen && ((svgTop < $(window).height() && svgTop > 0) || svgBottom > $(window).height() && svgBottom < 0)) {
        $("#animated_rocket").attr('src', animated_rocket.src);
        svgOnScreen = true;
    }

    else if ((svgTop >= $(window).height() || svgTop <= 0) && (svgBottom <= $(window).height() || svgBottom >= 0)) {
        svgOnScreen = false;
    }
}
