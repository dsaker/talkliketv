let items = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
let count = 0;
document.getElementById("rejectButton").addEventListener("click", nextItem);
function nextItem() {
    document.getElementById("displayItem").innerHTML = '{{(index .Phrases 0).Phrase}}';
    count += 1;
    console.log(count)
}