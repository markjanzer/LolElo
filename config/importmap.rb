# Pin npm packages by running ./bin/importmap

pin "application"

pin "application", preload: true
pin "react", to: "https://esm.sh/react@18"
pin "react-dom", to: "https://esm.sh/react-dom@18"
pin "@rails/ujs", to: "https://cdn.jsdelivr.net/npm/@rails/ujs@7.0.0"
pin "turbolinks", to: "https://cdn.jsdelivr.net/npm/turbolinks@5.2.0/dist/turbolinks.js"
pin "@rails/activestorage", to: "https://cdn.jsdelivr.net/npm/@rails/activestorage@7.0.0"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/components", under: "components"
pin "components/Chart", to: "components/Chart.jsx"