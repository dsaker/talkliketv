document.getElementById("from_english").addEventListener("click", function() {
    document.getElementById("language_id_label").textContent="To: ";
});

document.getElementById("to_english").addEventListener("click", function() {
    document.getElementById("language_id_label").textContent="From: ";
});

document.getElementById("translate_submit").addEventListener("click", function() {
    document.getElementById("translate_form").style.display = "none";
    document.getElementById("lds-div").style.display = "block";
});