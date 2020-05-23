"use strict";

var svgOnScreen = false;
var animated_rocket = new Image();
animated_rocket.src = "assets/sideways_rocket_animated.svg";

$(document).ready(start);

function start(){
    $(window).scroll(change_bar);
    $(window).scroll(playSVG);
    $(window).resize(setLoginPos);

    var modal = document.getElementById("loginForm");
    // var clickCount = 0;

    window.onclick = function(event) {
      if (event.target == modal) {
        modal.style.display = "none";
      }

      // if ($("#mobile-nav").hasClass("responsive") && ($(this) == $("a[href='#about_us']") || $(this) != $("#mobile-nav"))) {
      //     clickCount++;
      //     if (clickCount > 1) {
      //         $("#mobile-nav").removeClass("responsive");
      //         clickCount = 0;
      //     }
      // }
      // else clickCount = 0;
    }

    var now = new Date();

    var day = ("0" + now.getDate()).slice(-2);
    var month = ("0" + (now.getMonth() + 1)).slice(-2);

    var today = now.getFullYear()+"-"+(month)+"-"+(day) ;
    $('#outbound_date').val(today);
}

function change_bar() {
    if($(window).scrollTop()>630){
        $('#topnav').addClass('bar_colour');
    }
    else if (!$("#mobile-nav").hasClass("responsive")) {
        $('#topnav').removeClass('bar_colour');
    }
}

function openForm() {
    document.getElementById("loginForm").style.display = "block";
    setLoginPos();
}

function closeForm() {
    document.getElementById("loginForm").style.display = "none";
}

function makeBarResponsive() {
    if(!$("#mobile-nav").hasClass("responsive")) {
        $("#mobile-nav").addClass("responsive");
        $("#topnav").addClass("bar_colour");
    }
    else {
        $("#mobile-nav").removeClass("responsive");
        change_bar();
    }
}

function setLoginPos() {
    var height = $(window).height();
    var loginHeight = $("#loginFormContent").height();
    $("#loginForm").css("padding-top", (height-loginHeight)/2);
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
