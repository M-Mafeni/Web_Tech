$(document).ready(start);
function start(){
    $(window).scroll(change_bar);
}
function change_bar() {
    if($(window).scrollTop()>630){
        $('nav').addClass('bar_colour');
    }else{
        $('nav').removeClass('bar_colour');
    }
}
