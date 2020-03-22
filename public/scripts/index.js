"use strict";

$(document).ready(start);

function start(){
    $(window).scroll(change_bar);

    var modal = document.getElementById("loginForm");
    window.onclick = function(event) {
      // console.log("clicked");
      if (event.target == modal) {
        modal.style.display = "none";
      }
    }
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
