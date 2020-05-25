"use strict";

$(document).ready(start);

function start(){
    $(window).scroll(change_bar);
    $(window).resize(setLoginPos);
    $("#mobile-nav-bg").click(closeNav);

    var modal = document.getElementById("loginForm");

    window.onclick = function(event) {
      if (event.target == modal) {
        modal.style.display = "none";
      }

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
        $("#mobile-nav-bg").show();
    }
    else {
        closeNav();
    }
}

function setLoginPos() {
    var height = $(window).height();
    var loginHeight = $("#loginFormContent").height();
    $("#loginForm").css("padding-top", (height-loginHeight)/2);
}

function closeNav() {
    $("#mobile-nav").removeClass("responsive");
    change_bar();
    $("#mobile-nav-bg").hide();
}
