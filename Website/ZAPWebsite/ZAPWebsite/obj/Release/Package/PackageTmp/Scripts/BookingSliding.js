//Get the parameters from url
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
//The input dates
var resStart = document.getElementById("MainContent_resStart");
var resEnd = document.getElementById("MainContent_resEnd");



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

//When page loaded
$(document).ready(function () {
    if (!isPostBack) {

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
        // show default page, but if params exists then show the second page
        if (CheckParams()) {
            showPage(2)
        }
        else {
            showPage(0);
        }
        //Binds the <a> to showPage function
        $('a.l1').click(showPage.bind(null, 0));
        $('a.l2').click(showPage.bind(null, 1));
        $('a.l3').click(showPage.bind(null, 2));

        //animates the sliding
        $('.left-right').mouseover(function () {
            $('.slider').stop().animate({
                right: 0
            }, 400);
        }).mouseout(function () {
            $('.slider').stop().animate({
                right: '-200px'
            }, 400);
        });
    }
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
function SpecialSale() {
    if (CheckSale()) {
        var sale = urlParams.get("sale");
        if (sale = "1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen") {

        }
    }
}


function AddParams() {
    //Get the current url
    var startURL = window.location.origin + window.location.pathname;
    console.log(startURL);
    //Add some parameters to the url
    startURL += "?startDate=1&endDate=2%typeName=none&sale=false";
    console.log(startURL);
    //Make the string into an object
    var url = new URL(startURL);

    //Find values
    var startDate = new Date(document.getElementById("MainContent_resStart").value).toDateString();
    var endDate = new Date(document.getElementById("MainContent_resEnd").value).toDateString();
    var typeName = document.getElementById("MainContent_DropDownTypes").value;

    //Set the parameters into the above url object
    url.searchParams.set('startDate', startDate);
    url.searchParams.set('endDate', endDate);
    url.searchParams.set('typeName', typeName);

    //If there is a sale parameter, then send it to the order page
    if (CheckSale()) {
        var currentURL = new URL(window.location.href);
        url.searchParams.set('sale', currentURL.searchParams.get("sale"));
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