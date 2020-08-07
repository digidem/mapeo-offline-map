#!/usr/bin/env node

const { multiLineString, featureCollection } = require('@turf/helpers')

const lineStrings = {
  10: [],
  1: [],
  0.1: []
}
const MAX_LAT = 85.05

for (let lon = -180; lon <= 180; lon = +(lon + 0.1).toFixed(1)) {
  const interval = lon % 10 === 0 ? 10 : lon % 1 === 0 ? 1 : 0.1
  lineStrings[interval].push([
    [lon, -MAX_LAT],
    [lon, MAX_LAT]
  ])
}

for (let lat = -MAX_LAT; lat <= MAX_LAT; lat = +(lat + 0.1).toFixed(1)) {
  const interval = lat % 10 === 0 ? 10 : lat % 1 === 0 ? 1 : 0.1
  lineStrings[interval].push([
    [-180, lat],
    [180, lat]
  ])
}

const fc = featureCollection(
  Object.keys(lineStrings).map(interval => {
    return multiLineString(lineStrings[interval], { interval })
  })
)

process.stdout.write(JSON.stringify(fc))
