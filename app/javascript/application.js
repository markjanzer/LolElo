// Entry point for the build script in your package.json

import { initSentry } from './sentry-config';
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"

// Importing React and ReactDOM
import React from "react"
import { createRoot } from 'react-dom/client';

// Importing your custom Chart component
import Chart from "./components/Chart";

// Start sentry monitoring
initSentry();
// Start Rails utilities
Rails.start();
Turbolinks.start();
ActiveStorage.start();

// Event listener for Turbolinks
document.addEventListener("turbolinks:load", () => {
  if (document.body.dataset["route"] === "series-show") {
    const node = document.getElementById("chart");
    if (node) {
      const root = createRoot(node);
      const data = JSON.parse(node.getAttribute("data"));
  
      root.render(<Chart data={data.chartData} />);
    }
  }
});