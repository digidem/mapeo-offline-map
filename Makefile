BIN := ./node_modules/.bin
space := $(eval) $(eval)
comma := ,
TMPDIR := intermediate
ZIPDIR := $(TMPDIR)/zip
SHPDIR := $(TMPDIR)/shp
JSONDIR := $(TMPDIR)/json
SIMPLIFY = node --max_old_space_size=8192 bin/simplify
OGR_OPTIONS := -lco COORDINATE_PRECISION=2 -lco WRITE_NAME=NO -lco RFC7946=YES

clean:
	rm -rf dist
	rm -rf $(TMPDIR)

all: dist/style.json

#################
# Download data #
#################

NE_URL := https://naciscdn.org/naturalearth/

$(ZIPDIR)/%.zip:
	mkdir -p $(dir $@)
	curl -L -o $@ --raw '$(NE_URL)$*.zip'

########################
# Define Zip archives  #
########################

$(SHPDIR)/ne_50m_rivers_lake_centerlines_scale_rank.shp: $(ZIPDIR)/50m/physical/ne_50m_rivers_lake_centerlines_scale_rank.zip

$(SHPDIR)/ne_50m_land.shp: $(ZIPDIR)/50m/physical/ne_50m_land.zip

$(SHPDIR)/ne_110m_admin_0_boundary_lines_land.shp: $(ZIPDIR)/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip

$(SHPDIR)/ne_50m_populated_places.shp: $(ZIPDIR)/50m/cultural/ne_50m_populated_places.zip

$(SHPDIR)/ne_50m_lakes.shp: $(ZIPDIR)/50m/physical/ne_50m_lakes.zip

#########################
# Extract Zip archives  #
#########################

$(SHPDIR)/ne_%.shp:
	mkdir -p $(dir $@)
	unzip -o $< -d $(dir $@)
	touch $@

################################
# Convert shp files to GeoJSON #
################################

$(JSONDIR)/lakes.json: $(SHPDIR)/ne_50m_lakes.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'GeoJSON' $(OGR_OPTIONS) $@ $< -select scalerank,name

$(JSONDIR)/places.json: $(SHPDIR)/ne_50m_populated_places.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'GeoJSON' $(OGR_OPTIONS) $@ $< -select SCALERANK,NAME

$(JSONDIR)/rivers.json: $(SHPDIR)/ne_50m_rivers_lake_centerlines_scale_rank.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'GeoJSON' $(OGR_OPTIONS) $@ $< -select min_zoom,strokeweig


$(JSONDIR)/land.json: $(SHPDIR)/ne_50m_land.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'GeoJSON' $(OGR_OPTIONS) $@ $< -dialect sqlite -sql "SELECT ST_Union(geometry) FROM $(basename $(notdir $<))"

$(JSONDIR)/boundaries.json: $(SHPDIR)/ne_110m_admin_0_boundary_lines_land.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'GeoJSON' $(OGR_OPTIONS) $@ $< -dialect sqlite -sql "SELECT ST_Union(geometry) FROM $(basename $(notdir $<))"

$(JSONDIR)/graticule.json:
	scripts/graticule.js > $@

dist/style.json: $(JSONDIR)/rivers.json $(JSONDIR)/land.json $(JSONDIR)/boundaries.json $(JSONDIR)/lakes.json $(JSONDIR)/graticule.json
	mkdir -p $(dir $@)
	jq --slurpfile rivers $(JSONDIR)/rivers.json \
		 --slurpfile land $(JSONDIR)/land.json \
		 --slurpfile boundaries $(JSONDIR)/boundaries.json \
		 --slurpfile lakes $(JSONDIR)/lakes.json \
		 --slurpfile graticule $(JSONDIR)/graticule.json \
		 '.sources += { \
			  "rivers": {"type": "geojson", "data": $$rivers[0]}, \
				"land": {"type": "geojson", "data": $$land[0]}, \
				"boundaries": {"type": "geojson", "data": $$boundaries[0]}, \
				"lakes": {"type": "geojson", "data": $$lakes[0]}, \
				"graticule": {"type": "geojson", "data": $$graticule[0]} \
		 }' \
		 style-no-sources.json > $@
