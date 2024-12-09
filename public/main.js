let menuButton = document.querySelector("#menu-button")
let menu = document.querySelector(".menu")

function show(){
    menu.classList.toggle("show-menu")
}
menuButton.addEventListener("click",show)