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



function searchFilter() {
    var input, filter, list, cards, i, title, txtValue;
    input = document.getElementById("search-bar");
    filter = input.value.toUpperCase();
    list = document.querySelector('.card-wrapper');
    cards = list.getElementsByClassName('card');

    for (i=0; i < cards.length; i++) {
        title = cards[i].getElementsByTagName('h4')[0];
        txtValue = title.innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            cards[i].style.display = "";
        } else {
            cards[i].style.display = "none";
        }
    }
}