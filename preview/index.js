/* global mapboxgl */
var style = require('../style.json')

var sources = [
  {
    id: 'boundaries-source',
    data: require('../dist/boundaries.json')
  },
  {
    id: 'lakes-source',
    data: require('../dist/lakes.json')
  },
  {
    id: 'land-source',
    data: require('../dist/land.json')
  },
  {
    id: 'rivers-source',
    data: require('../dist/rivers.json')
  },
  {
    id: 'graticule-source',
    data: require('../dist/graticule.json')
  }
]

mapboxgl.accessToken =
  'pk.eyJ1IjoiZGlnaWRlbSIsImEiOiJuM3FabmNFIn0._gF6262MSzePWUChu4S9PA'
var map = (window.map = new mapboxgl.Map({
  container: 'map',
  style: {
    version: 8,
    name: 'Empty',
    sources: {},
    layers: []
  }
}))

map.on('load', function () {
  for (const { id, data } of sources) {
    map.addSource(id, { type: 'geojson', data: data })
  }
  for (const layer of style.layers) {
    map.addLayer(layer)
  }
})
