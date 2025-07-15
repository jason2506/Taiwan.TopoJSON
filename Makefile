MAPSHAPER = npx mapshaper

RAW_DIR = raw
CSV_DIR = csv
SPLIT_DIR = split
TOPOJSON_DIR = topojson

COUNTIES_SHP = $(RAW_DIR)/counties.shp
TOWNS_SHP = $(RAW_DIR)/towns.shp
VILLAGES_SHP = $(RAW_DIR)/villages.shp

COUNTIES_CSV = $(CSV_DIR)/counties.csv
TOWNS_CSV = $(CSV_DIR)/towns.csv
VILLAGES_CSV = $(CSV_DIR)/villages.csv

SPLIT_COUNTIES_PATH = $(SPLIT_DIR)/counties.shp
SPLIT_TOWNS_PATH = $(SPLIT_DIR)/towns
SPLIT_VILLAGES_PATH = $(SPLIT_DIR)/villages

TOPOJSON_COUNTIES_PATH = $(TOPOJSON_DIR)/counties.json
TOPOJSON_TOWNS_PATH = $(TOPOJSON_DIR)/towns
TOPOJSON_VILLAGES_PATH = $(TOPOJSON_DIR)/villages
TOPOJSON_TOWNS_FILES = $(patsubst $(SPLIT_TOWNS_PATH)/%.shp, $(TOPOJSON_TOWNS_PATH)/%.json, $(wildcard $(SPLIT_TOWNS_PATH)/*.shp))
TOPOJSON_VILLAGES_FILES = $(patsubst $(SPLIT_VILLAGES_PATH)/%.shp, $(TOPOJSON_VILLAGES_PATH)/%.json, $(wildcard $(SPLIT_VILLAGES_PATH)/*.shp))


SPLIT_COUNTIES_OPTS = \
		-rename-fields id=COUNTYCODE \
		-join $(COUNTIES_CSV) keys=id,id field-types=id:str \
	  -verbose \
		-filter-fields id,name
SPLIT_TOWNS_OPTS = \
		-rename-fields id=TOWNCODE \
		-join $(TOWNS_CSV) keys=id,id field-types=id:str \
		-split COUNTYCODE \
	  -verbose \
		-filter-fields id,name
SPLIT_VILLAGES_OPTS = \
		-rename-fields id=VILLCODE \
		-join $(VILLAGES_CSV) keys=id,id field-types=id:str \
		-split TOWNCODE \
	  -verbose \
		-filter-fields id,name


TOPOJSON_COUNTIES_OPTS = -simplify interval=400
TOPOJSON_TOWNS_OPTS = -simplify interval=200
TOPOJSON_VILLAGES_OPTS = -simplify interval=100


all: split-all topojson-all


$(SPLIT_COUNTIES_PATH): $(COUNTIES_SHP) $(COUNTIES_CSV)
	@mkdir -p $(dir $@)
	@${MAPSHAPER} $< encoding=big5 name=counties \
		$(SPLIT_COUNTIES_OPTS) \
		-o force $@

$(SPLIT_TOWNS_PATH): $(TOWNS_SHP) $(TOWNS_CSV)
	@mkdir -p $@
	@${MAPSHAPER} $< encoding=big5 name=towns \
		$(SPLIT_TOWNS_OPTS) \
		-o force $@

$(SPLIT_VILLAGES_PATH): $(VILLAGES_SHP) $(VILLAGES_CSV)
	@mkdir -p $@
	@${MAPSHAPER} $< encoding=big5 name=villages \
		$(SPLIT_VILLAGES_OPTS) \
		-o force $@

split-counties: $(SPLIT_COUNTIES_PATH)
split-towns: $(SPLIT_TOWNS_PATH)
split-villages: $(SPLIT_VILLAGES_PATH)
split-all: split-counties split-towns split-villages


$(TOPOJSON_COUNTIES_PATH): $(SPLIT_COUNTIES_PATH)
	@mkdir -p $(dir $@)
	@${MAPSHAPER} $< encoding=utf-8 name=map \
		$(TOPOJSON_COUNTIES_OPTS) \
		-o force bbox $@ format=topojson

$(TOPOJSON_TOWNS_PATH):
	@mkdir -p $@

$(TOPOJSON_TOWNS_PATH)/%.json: $(SPLIT_TOWNS_PATH)/%.shp | $(TOPOJSON_TOWNS_PATH)
	@${MAPSHAPER} $< encoding=utf-8 name=map \
		$(TOPOJSON_TOWNS_OPTS) \
		-o force bbox $@ format=topojson

$(TOPOJSON_VILLAGES_PATH):
	@mkdir -p $@

$(TOPOJSON_VILLAGES_PATH)/%.json: $(SPLIT_VILLAGES_PATH)/%.shp | $(TOPOJSON_VILLAGES_PATH)
	@${MAPSHAPER} $< encoding=utf-8 name=map \
		$(TOPOJSON_VILLAGES_OPTS) \
		-o force bbox $@ format=topojson

topojson-counties: $(TOPOJSON_COUNTIES_PATH)
topojson-towns: $(TOPOJSON_TOWNS_FILES)
topojson-villages: $(TOPOJSON_VILLAGES_FILES)
topojson-all: topojson-counties topojson-towns topojson-villages


clean-split-counties:
	rm -f $(SPLIT_COUNTIES_PATH)

clean-split-towns:
	rm -rf $(SPLIT_TOWNS_PATH)

clean-split-villages:
	rm -rf $(SPLIT_VILLAGES_PATH)

clean-split:
	rm -rf $(SPLIT_DIR)

clean-topojson-counties:
	rm -f $(TOPOJSON_COUNTIES_PATH)

clean-topojson-towns:
	rm -rf $(TOPOJSON_TOWNS_PATH)

clean-topojson-villages:
	rm -rf $(TOPOJSON_VILLAGES_PATH)

clean-topojson:
	rm -rf $(TOPOJSON_DIR)

clean: clean-split clean-topojson


.PHONY: clean \
	clean-split-counties clean-split-towns clean-split-villages clean-split \
	clean-topojson-counties clean-topojson-towns clean-topojson-villages clean-topojson
