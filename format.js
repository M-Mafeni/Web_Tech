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
            return "January";
        case "02":
            return "February";
        case "03":
            return "March";
        case "04":
            return "April";
        case "05":
            return "May";
        case "06":
            return "June";
        case "07":
            return "July";
        case "08":
            return "August";
        case "09":
            return "September";
        case "10":
            return "October";
        case "11":
            return "November";
        case "12":
            return "December";
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
module.exports.formatDate = formatDate;
// formatDate("2020-03-20");
