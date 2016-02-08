/* globals d3 topojson */
(function() {
    'use strict';

    var width = 800,
        height = 600,
        svg = d3.select('#js-map'),
        tooltip = d3.select('#js-tooltip'),
        load,
        parseQueryString,
        params;

    svg.attr('width', width)
        .attr('height', height);

    load = function(type, id) {
        var filepath = 'https://raw.githubusercontent.com/' +
            'jason2506/Taiwan.TopoJSON/master/topojson/' +
            (type === 'towns' ? 'towns/towns-' + id :
                (type === 'villages' ? 'villages/villages-' + id :
                    'counties')) + '.json';

        d3.json(filepath, function(data) {
            var features = topojson.feature(data, data.objects.map).features,
                bbox = data.bbox,
                scale = Math.min(width / (bbox[2] - bbox[0]),
                                 height / (bbox[3] - bbox[1])) * 50,
                center = [(bbox[2] + bbox[0]) / 2, (bbox[3] + bbox[1]) / 2],
                projection,
                path;

            projection = d3.geo.mercator()
                .center(center)
                .scale(scale)
                .translate([width / 2, height / 2]);

            path = d3.geo.path()
              .projection(projection);

            svg.selectAll('path')
                .data(features)
                .enter()
                .append('path')
                    .attr('d', path)
                    .on('click', function(d) {
                        var id,
                            t;

                        if (!d3.event) {
                            return;
                        }

                        id = d.properties.id;
                        d3.event.stopPropagation();
                        if (type === 'villages') {
                            return;
                        } else if (type === 'towns') {
                            t = 'villages';
                        } else {
                            t = 'towns';
                        }

                        location.search = unescape(encodeURI('type=' + t + '&id=' + id));
                    })
                    .on('mouseover', function(d) {
                        var centroid = path.centroid(d);

                        tooltip
                            .classed('s-show', true)
                            .style('left', centroid[0] + 'px')
                            .style('top', (centroid[1] - 20) + 'px')
                            .text(d.properties.name);
                    })
                    .on('mouseout', function() {
                        tooltip
                            .classed('s-show', false);
                    });
        });
    };

    parseQueryString = function(queryString) {
        var queries = queryString.split('&'),
            result = {},
            tokens,
            length,
            i;

        for (i = 0, length = queries.length; i < length; i++) {
            tokens = queries[i].split('=');
            result[tokens[0]] = tokens[1];
        }

        return result;
    };

    params = parseQueryString(location.search.substr(1));
    load(params['type'], params['id']);
})();
