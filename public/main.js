let menubutton = document.querySelector(".menu-button")
let menu = document.querySelector(".menu")

function show(){
    menu.classList.toggle("show-menu")
}
menubutton.addEventListener("click",show)