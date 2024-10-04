/* global mapboxgl */
var style = require('../dist/style.json')

new mapboxgl.Map({
  container: 'map',
  style
})
