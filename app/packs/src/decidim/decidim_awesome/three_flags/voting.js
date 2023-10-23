document.addEventListener("DOMContentLoaded", () => {
  const abstainButton = document.querySelector(".abstain-button");
  const rectangles = document.querySelectorAll(".rectangle");
  let abstained = false;

  abstainButton.addEventListener("click", event => {
    event.preventDefault();

    abstained = !abstained;

    rectangles.forEach(rectangle => {
      rectangle.style.opacity = abstained ? "0.3" : "1";
      rectangle.style.pointerEvents = abstained ? "none" : "auto";
    });
  });
});
