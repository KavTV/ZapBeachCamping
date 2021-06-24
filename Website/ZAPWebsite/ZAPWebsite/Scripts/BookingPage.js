var seasonCheckbox = document.getElementById("MainContent_SeasonPlaceCheck");
var resStart = document.getElementById("MainContent_resStart");
var resEnd = document.getElementById("MainContent_resEnd");

//Make sure they cant select dates older than today
//Get todays date
var tomorrow = new Date();
//Add a day, because we dont want people to reserve at the same day
tomorrow.setDate(tomorrow.getDate() + 1);
//Split it into yyyy-mm-dd
tomorrow = tomorrow.toISOString().split('T')[0];
//Set the minimum date
resStart.setAttribute('min', tomorrow);
resEnd.setAttribute('min', tomorrow);

//If season is selected, then 
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

function onResStartChanged() {
    var startDate = new Date(resStart.value);
    //Take startdate and add 7 days
    startDate.setDate(startDate.getDate() + 7);
    //Then format it to yyyy-mm-dd
    resEnd.value = startDate.toISOString().split('T')[0];

}