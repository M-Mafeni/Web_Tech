"use strict";

$(document).ready(start);

function start(){
    $(window).scroll(change_bar);
    $(window).resize(setLoginPos);
    $("#mobile-nav-bg").click(closeNav);
    $("#about_nav_link").click(closeNav);

    // close the login form by clicking outside of it
    var modal = document.getElementById("loginForm");
    window.onclick = function(event) {
        if (event.target == modal) {
            closeForm();
        }
    }
}

// fix login form at centre of page
function setLoginPos() {
    var height = $(window).height();
    var loginHeight = $("#loginFormContent").height();
    $("#loginForm").css("padding-top", (height-loginHeight)/2);
}

function openForm() {
    document.getElementById("loginForm").style.display = "block";
    setLoginPos();
}

function closeForm() {
    document.getElementById("loginForm").style.display = "none";
}

// on the main page, change nav bar to be opaque in the about section
function change_bar() {
    if($(window).scrollTop()>630){
        $('#topnav').addClass('bar_colour');
    }
    else if (!$("#mobile-nav").hasClass("responsive")) {
        $('#topnav').removeClass('bar_colour');
    }
}

// mobile nav bar
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

function closeNav() {
    $("#mobile-nav").removeClass("responsive");
    change_bar();
    $("#mobile-nav-bg").hide();
}
