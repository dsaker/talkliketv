let count = 0;

function removePunctuation(text) {
    let punctuation = /[\.,?!]/g;
    let newText = text.replace(punctuation, "");
    return newText;
}

function nextPhrase() {
    document.getElementById("phrase" + count).style.display = "none";
    count ++;
    document.getElementById("phrase" + count).style.display = "block";
    console.log(count)
}

document.getElementById("rejectButton").addEventListener("click", reject);
function reject() {
    nextPhrase();
}

document.getElementById("acceptButton").addEventListener("click", accept);
function accept() {
    nextPhrase()
}

document.getElementById("hintButton").addEventListener("click", hint);
function hint() {
    let phrase = document.getElementById("answer" + count).innerText;
    phrase = removePunctuation(phrase);

    let newString = phrase[0];
    for (let i = 1; i < phrase.length; i++) {
        if (phrase[i-1] === " ") {
            newString += phrase[i];
        }
        else {
            newString += "_";
        }
    }
    document.getElementById("solution" + count).placeholder = newString;
}

document.getElementById("showButton").addEventListener("click", show);
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