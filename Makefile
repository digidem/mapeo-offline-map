BIN := ./node_modules/.bin
space := $(eval) $(eval)
comma := ,
TMPDIR := intermediate
ZIPDIR := $(TMPDIR)/zip
SHPDIR := $(TMPDIR)/shp
SIMPLIFY = node --max_old_space_size=8192 bin/simplify
OGR_OPTIONS := -lco COORDINATE_PRECISION=2 -lco WRITE_NAME=NO -lco RFC7946=YES

clean:
	rm -rf build
	rm -rf $(TMPDIR)
	rm -rf geojson

all: dist/rivers.json dist/land.json dist/boundaries.json dist/lakes.json

#################
# Download data #
#################

NE_URL := https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/

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

dist/lakes.json: $(SHPDIR)/ne_50m_lakes.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'GeoJSON' $(OGR_OPTIONS) $@ $< -select scalerank,name

dist/places.json: $(SHPDIR)/ne_50m_populated_places.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'GeoJSON' $(OGR_OPTIONS) $@ $< -select SCALERANK,NAME

dist/rivers.json: $(SHPDIR)/ne_50m_rivers_lake_centerlines_scale_rank.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'GeoJSON' $(OGR_OPTIONS) $@ $< -select min_zoom,strokeweig


dist/land.json: $(SHPDIR)/ne_50m_land.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'GeoJSON' $(OGR_OPTIONS) $@ $< -dialect sqlite -sql "SELECT ST_Union(geometry) FROM $(basename $(notdir $<))"

dist/boundaries.json: $(SHPDIR)/ne_110m_admin_0_boundary_lines_land.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'GeoJSON' $(OGR_OPTIONS) $@ $< -dialect sqlite -sql "SELECT ST_Union(geometry) FROM $(basename $(notdir $<))"
