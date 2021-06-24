var seasonCheckbox = document.getElementById("MainContent_SeasonPlaceCheck");
var resStart = document.getElementById("MainContent_resStart");
var resEnd = document.getElementById("MainContent_resEnd");

//Make sure they cant select dates older than today
//Get todays date
var startMin = new Date();
var endMin = new Date();
//Add a day, because we dont want people to reserve at the same day
startMin.setDate(startMin.getDate() + 1);
//End date should not be same day as reservation
endMin.setDate(endMin.getDate() + 2);
//Split it into yyyy-mm-dd
startMin = startMin.toISOString().split('T')[0];
endMin = endMin.toISOString().split('T')[0];
//Set the minimum date
resStart.setAttribute('min', startMin);
resEnd.setAttribute('min', endMin);

//If season is selected, then disable 
if (seasonCheckbox != null) {

    if (seasonCheckbox.checked) {
        resStart.disabled = true;
        resEnd.disabled = true;
    }
    else {
        resStart.disabled = false;
        resEnd.disabled = false;
    }
}
function enddateHigher() {
    var startDate = new Date(resEnd.value);
    var endDate = new Date(resStart.value);

    if (endDate > startDate) {
        console.log(endDate);
        console.log(startDate);
        endDate.setDate(endDate.getDate() + 1);
        resEnd.value = endDate.toISOString().split('T')[0];
    }
}

function onResStartChanged() {
    var startDate = new Date(resStart.value);
    //Take startdate and add 7 days
    startDate.setDate(startDate.getDate() + 7);
    //Then format it to yyyy-mm-dd
    resEnd.value = startDate.toISOString().split('T')[0];

}