// let menuButton = document.querySelector("#menu-button")
// let menu = document.querySelector(".menu")

// function show(){
//     menu.classList.toggle("show-menu")
// }
// menuButton.addEventListener("click",show)

let menuButton = document.querySelector(".menu-button")
let menu = document.querySelector(".menu")
// let fade_layer = document.querySelector(".fade-layer")
// let header = document.querySelector("header")

let burgerOne = document.querySelector("#burger-one")
let burgerTwo = document.querySelector("#burger-two")
let burgerThree = document.querySelector("#burger-three")

function show(){
    menu.classList.toggle("show-menu")
    // fade_layer.classList.toggle("visible")

    burgerOne.classList.toggle("animation-one")
    burgerOne.classList.toggle("reverse-one")

    burgerTwo.classList.toggle("animation-two")
    burgerTwo.classList.toggle("reverse-two")

    burgerThree.classList.toggle("animation-3")
    burgerThree.classList.toggle("reverse-3")
}

// fade_layer.addEventListener("click",show)
menuButton.addEventListener("click",show)
