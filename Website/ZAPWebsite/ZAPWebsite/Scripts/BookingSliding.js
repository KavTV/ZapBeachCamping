﻿const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
if (isPostBack) {
    console.log("POSTBACK WUUHU");
}
//Hide or show the divs hidden in the slider.
if (CheckParams()) {
    $('div.l1').hide();
    $('div.l2').show();
    $('div.l3').hide();
}
else {
    $('div.l2').show();
    $('div.l2').hide();
    $('div.l3').hide();
}
console.log(CheckParams());

$(document).ready(function () {
    var currentPageI = -1;
    var pages = [
        $('div.l1'),
        $('div.l2'),
        $('div.l3'),
    ];
    //Get the width of the div and save
    var viewsWidth = document.getElementById("leftrightdiv").offsetWidth
    console.log(document.getElementById("leftrightdiv").offsetWidth);
    var showPage = function (index) {
        if (index === currentPageI) { return; }
        var currentPage = pages[currentPageI];
        if (currentPage) {
            currentPage.stop().animate({ left: -viewsWidth }, function () {
                // will be called when the element finishes fading out
                // if selector matches multiple elements it will be called once for each
                currentPage.hide();
            });


        }
        var nextPage = pages[index];
        nextPage.show();
        nextPage
            .stop()
            .css({ left: viewsWidth })
            .animate({ left: 0 })
        currentPageI = index;

    }
    // show default page if params exists then show the second page
    if (CheckParams()) {
        showPage(2)
    }
    else {
        showPage(0);
    }
    $('a.l1').click(showPage.bind(null, 0));
    $('a.l2').click(showPage.bind(null, 1));
    $('a.l3').click(showPage.bind(null, 2));

    $('.left-right').mouseover(function () {
        $('.slider').stop().animate({
            right: 0
        }, 400);
    }).mouseout(function () {
        $('.slider').stop().animate({
            right: '-200px'
        }, 400);
    });

});
function CheckParams() {
    var startDate = urlParams.get("startDate");
    var endDate = urlParams.get("endDate");
    var typeName = urlParams.get("typeName");
    if (startDate != "Invalid" && endDate != "Invalid" && typeName != null) {
        return true;
    }
    else {
        return false;
    }
}
function CheckSale() {
    var sale = urlParams.get("sale");
    if (sale != null) {
        return true;
        console.log("truee");
    }
    else {
        return false;
        console.log("falsee");
    }
}


function AddParams() {
    //Get the current url
    var startURL = window.location;
    //Add some parameters to the url
    startURL += "?startDate=1&endDate=2%typeName=none&sale=false";
    console.log(startURL);
    //Make the string into an object
    var url = new URL(startURL);

    //Find values
    var startDate = new Date(document.getElementById("resStart").value).toDateString();
    var endDate = new Date(document.getElementById("resEnd").value).toDateString();
    var typeName = document.getElementById("MainContent_DropDownTypes").value;
    
    //Set the parameters into the above url object
    url.searchParams.set('startDate', startDate);
    url.searchParams.set('endDate', endDate);
    url.searchParams.set('typeName', typeName);
    //If there is a sale parameter, then send it to the order page
    if (CheckSale()) {
        url.searchParams.set('sale', url.searchParams.get("sale"));
        console.log("param set to true");
    }
    else {
        url.searchParams.set('sale', "false");
        console.log("param set to false");
    }
    console.log(url);
    //Redirect to the created url
    window.location.replace(url);
}