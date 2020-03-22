"use strict";
//gets the letters you put after a day (th,nd,st)
function getDay(day){
    if (day.endsWith("1") && day !== "11"){
        return day + "st";
    }else if(day.endsWith("2")){
        return day + "nd";
    }else if(day.endsWith("3")){
        return day + "rd";
    }else{
        return day + "th";
    }
}
function getMonth(month){
    switch (month) {
        case "01":
            return "Jan";
        case "02":
            return "Feb";
        case "03":
            return "Mar";
        case "04":
            return "Apr";
        case "05":
            return "May";
        case "06":
            return "Jun";
        case "07":
            return "Jul";
        case "08":
            return "Aug";
        case "09":
            return "Sep";
        case "10":
            return "Oct";
        case "11":
            return "Nov";
        case "12":
            return "Dec";
    }
}

function formatDate(date){
    let result = date.split("-");
    let year = result[0];
    let month = result[1];
    let day = result[2];
    day = getDay(day);
    month = getMonth(month);
    return day + " " + month + " " + year;
}

function formatTime(time){
    // remove the seconds - might be better to round?
    return time.substring(0, time.length-3);
}

module.exports.formatDate = formatDate;
module.exports.formatTime = formatTime;
// formatDate("2020-03-20");
