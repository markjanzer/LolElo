const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Lato', ...defaultTheme.fontFamily.sans],
      },
    },
    extend: {
      colors: {
        'core-purple-1': "hsl(276, 100%, 6%)",
        'core-purple-2': "hsl(276, 100%, 9%)",
        'core-organge-90': "hsl(35, 100%, 90%)",
        'core-green-41': "hsl(155, 100%, 41%)",
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
