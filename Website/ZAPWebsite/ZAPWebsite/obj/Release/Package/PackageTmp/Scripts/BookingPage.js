var checkbox = document.getElementById("MainContent_SeasonPlaceCheck");
var resStart = document.getElementById("MainContent_resStart");
var resEnd = document.getElementById("MainContent_resEnd");

if (checkbox != null) {

    if (checkbox.checked) {
        resStart.disabled = true;
        resEnd.disabled = true;
    }
    else {
        resStart.disabled = false;
        resEnd.disabled = false;
    }
}

function onResStartChanged() {
    var startDate = new Date(resStart.value);
    //Take startdate and add 7 days
    startDate.setDate(startDate.getDate() + 7);
    //Then format it to yyyy-mm-dd
    resEnd.value = startDate.toISOString().split('T')[0];

}