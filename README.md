# mapeo-offline-map

[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

Fallback offline map data and styles for Mapeo

This repo will download and build GeoJSON files for a basic offline map for
Mapeo which is used when no internet connection is available and no custom
offline map is installed. It is bundled with the app, so the data needs to be as
small as possible. Currently the map is loaded via geojson files, so they will
all be in memory, so files should be less than 5Mb uncompressed to avoid high
memory usage. In the future we may switch to building a tileset with basic
global data, but this might also increase filesize, although it will reduce
memory usage (since the whole dataset does not need to be loaded into memory
when displaying a map with a tileset).

## Table of Contents

- [Build](#build)
- [Preview](#preview)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Build

Make sure to have [GDAL](https://gdal.org/) installed in your system. To build all the map data files

```sh
npm run build
```

## Preview

```sh
npm start
```

## Maintainers

[@digidem](https://github.com/digidem)

## Contributing

PRs accepted.

Uses `Makefile` to download and process data from https://naturalearthdata.com.
Map style layers are defined in `layers.json`. To preview the map style run `npm
start`. It should automatically reload if you change `layers.json`.

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

MIT © 2020 Digital Democracy
