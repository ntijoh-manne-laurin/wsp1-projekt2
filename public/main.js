let menubutton = document.querySelectorAll(".menu-button")
let menu = document.querySelector(".menu")

function show(){
    menu.classList.toggle("show-menu")
}
menubutton.addEventListener("click",show)