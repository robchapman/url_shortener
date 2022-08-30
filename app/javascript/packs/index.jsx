import React from "react";
import { render } from "react-dom";
import Home from "../components/Home";
console.log('KJASGKHKH');

document.addEventListener("DOMContentLoaded", () => {
  render(
    <Home />,
    document.body.appendChild(document.createElement("div"))
  );
});
