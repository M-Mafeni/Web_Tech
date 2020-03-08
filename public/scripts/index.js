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
    }else{
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
  console.log($('#topnav').hasClass('responsive'));
  if(!($('#topnav').hasClass('responsive'))){
      $('#topnav').addClass('responsive');
  }else{
      $('#topnav').removeClass('responsive');
  }
}