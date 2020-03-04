$(document).ready(function(){
    $(window).scroll(function(){
        if($(window).scrollTop()>300){
            $('nav').addClass('bar_colour');
        }else{
            $('nav').removeClass('bar_colour');
        }
    });

});
