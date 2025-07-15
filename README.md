# Taiwan.TopoJSON

本專案旨在提供方便視覺化的臺灣行政區域與村里界線圖資。

為了減輕讀取負擔與減小單一檔案大小，本專案會將政府資料開放平台提供的原始圖資（Shapefile 格式，`.shp`）轉檔為 [TopoJSON](https://github.com/mbostock/topojson) 格式，並切割成三個層級：

* `topojson/counties.json`：全國各直轄市與縣市邊界。
* `topojson/towns/*.json`：各直轄市與縣市獨立一份檔案，檔名為其行政區代碼。包含其轄區下的各個鄉鎮市區邊界。
* `topojson/villages/*.json`：各鄉鎮市區獨立一份檔案，檔名為其行政區代碼。包含其轄區下的各個村里邊界。

若是想要自行填入各行政區與村里對應的資料，僅需修改 `csv/` 目錄下的檔案，並自行添加所需欄位。再修改 `Makefile` 檔，在 `SPLIT_COUNTIES_OPTS`、`SPLIT_TOWNS_OPTS` 或 `SPLIT_VILLAGES_OPTS` 的 `-filter-fields` 後加上要包含的欄位名稱（以逗號隔開）。最後重新生成 TopoJSON 檔即可（建置方法請見下節）。

註：欲查詢行政區域與村里代碼請參考[這裡](http://www.dgbas.gov.tw/ct.asp?xItem=951&ctNode=5485)。


## 建置方式

`topojson/` 目錄下已有預建置好的基本圖資（資料僅有行政區／村里代碼與名稱）。

要重新生成 TopoJSON 檔，請先從下節「資料來源」下載所需的原始檔案，並解壓縮到 `raw/` 目錄中。

**重要：** 為了讓建置流程順利運作，請將解壓縮後的 `Shapefile`（包含 `.shp`, `.shx`, `.dbf` 等副檔名）依照以下規則重新命名：
*   直轄市、縣市界線圖資 -> `counties` (例如 `COUNTY_MOI_1060525.shp` -> `counties.shp`)
*   鄉鎮市區界線圖資 -> `towns` (例如 `TOWN_MOI_1061130.shp` -> `towns.shp`)
*   村里界圖圖資 -> `villages` (例如 `VILLAGE_NLSC_1140620.shp` -> `villages.shp`)

接著，安裝 [mapshaper](https://github.com/mbloch/mapshaper)（若尚未安裝），並執行以下命令：

```
$ make split-all topojson-all
```

也可以將 `-all` 改成 `-counties`、`-towns` 或 `-villages`，僅生成特定層級的圖資。如：

```
$ make split-towns topojson-towns
```

僅會生成各直轄市與縣市的 TopoJSON 檔。

若是僅需特定行政區域或村里的 TopoJSON 檔，則直接指定生成的檔案名稱。舉例來說，如欲生成臺北市中正區（代碼 6300500）的各村里邊界檔，則需執行：

```
$ make villages/villages-6300500.json
```

## 踩坑紀錄
1. 如果遇到`make: Nothing to be done for ...`:

  執行 `make clean-..`. 命令，例如`clean-topojson-villages`

 `make`透過判斷「目標檔案」是否已經存在，以及它的「依賴檔案」是否比它更新，來決定是否需要執行某個命令。

## 資料來源

* [直轄市、縣市界線(TWD97經緯度) | 政府資料開放平台](http://data.gov.tw/node/7442)
* [鄉鎮市區界線(TWD97經緯度) | 政府資料開放平台](http://data.gov.tw/node/7441)
* [村里界圖(TWD97經緯度) | 政府資料開放平台](http://data.gov.tw/node/7438)
