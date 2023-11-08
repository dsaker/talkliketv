let count = 0;

function nextPhrase() {
    if (count === 9) {
        location.reload()
    }
    document.getElementById("phrase" + count).style.display = "none";
    count ++;
    document.getElementById("phrase" + count).style.display = "block";
    console.log(count)
}

document.getElementsByName("rejectButton").forEach(
    function (e) {e.addEventListener( "click", reject)});
function reject() {
    nextPhrase();
}

document.getElementsByName("hintButton").forEach(
    function (e) {e.addEventListener("click", hint)});
function hint() {
    let hint = document.getElementById("phraseHint" + count).value;
    console.log(hint)
    document.getElementById("solution" + count).placeholder = hint;
}

document.getElementsByName("phraseCorrectForm").forEach(
    function (form){
        form.addEventListener("click", function (e){
            e.preventDefault();
            fetch("/phrase/correct", {
                method: "POST",
                body: new FormData(form)
            })
                .then(function() {nextPhrase()})
                .catch(error => console.error(error));
        })
    })

document.getElementsByName("showButton").forEach(
    function (e){ e.addEventListener("click", show)});
function show() {
    let th = document.getElementById("answer" + count);
    if (th.style.display === "block") {
        th.style.display = "none";
    } else {
        th.style.display = "block";
    }
}

document.getElementById("startButton").addEventListener("click", start);
function start() {
    document.getElementById("phrase" + count).style.display = "block";
    document.getElementById("tableButtons").style.display = "block";
    document.getElementById("startButton").style.display = "none";
}