function openForm() {
  document.getElementById("loginForm").style.display = "block";
}

function closeForm() {
  document.getElementById("loginForm").style.display = "none";

}

// When the user clicks anywhere outside of the modal, close it
$(document).ready(start);
function start(){
    var modal = document.getElementById("loginForm");
    window.onclick = function(event) {
      // console.log("clicked");
      if (event.target == modal) {
        modal.style.display = "none";
      }
    }
}
