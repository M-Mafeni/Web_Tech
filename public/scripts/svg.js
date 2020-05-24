"use strict";

var svgOnScreen = false;
var animated_rocket = new Image();
animated_rocket.src = "assets/sideways_rocket_animated.svg";

$(document).ready(start);

function start() {
    $(window).scroll(playSVG);
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
