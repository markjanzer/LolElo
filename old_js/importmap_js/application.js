// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// Importing Rails utilities
import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";

// Importing React and ReactDOM via Import Maps
import React from "react";
import ReactDOM from "react-dom";

// Importing your custom Chart component
import Chart from "./components/Chart";

// Start Rails utilities
Rails.start();
Turbolinks.start();
ActiveStorage.start();

// Event listener for Turbolinks
document.addEventListener("turbolinks:load", () => {
  console.log("turbolinks:load");

  if (document.body.dataset["route"] === "series-show") {
    const node = document.getElementById("chart");
    const data = JSON.parse(node.getAttribute("data"));

    ReactDOM.render(React.createElement(Chart, { data }), node);
  }
});