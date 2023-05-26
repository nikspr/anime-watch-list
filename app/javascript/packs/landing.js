document.addEventListener("DOMContentLoaded", (event) => {
  const startButton = document.querySelector(".button-56");
  if (startButton) {
    startButton.addEventListener("click", () => {
      window.location.href = "/authorize";
    });
  }
});
