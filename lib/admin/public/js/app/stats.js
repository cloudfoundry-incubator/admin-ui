
var Stats =
{
    buildStatsData: function(rows)
    {
        var lines = {};

        lines["organizations"]     = [];
        lines["spaces"]            = [];
        lines["users"]             = [];
        lines["apps"]              = [];
        lines["total_instances"]   = [];
        lines["running_instances"] = [];
        lines["deas"]              = [];

        for (var index in rows)
        {
            var item = rows[index][8];

            var entryDate = new Date(item.timestamp);

            for (var line in lines)
            {
                var entry = [];

                entry.push(entryDate);

                if ((item[line] != null) && (item[line] > 0))
                {
                    entry.push(item[line]); 
                    lines[line].push(entry);
                }
            }
        }

        return [lines["organizations"], lines["spaces"], lines["users"], lines["apps"], lines["total_instances"], lines["running_instances"]];  
    },

    createStatsChart: function(chartID, data)
    {
        return $.jqplot(chartID, 
                        data, 
                        {
                            title: "",
                            animate: true,
                            animateReplot: true,
                            axes:
                            {
                                xaxis:
                                {
                                    renderer: $.jqplot.DateAxisRenderer,
                                    tickRenderer: $.jqplot.CanvasAxisTickRenderer,
                                    tickOptions:
                                    {
                                        formatString: "%b %d"
                                    }
                                }
                            },
                            series:
                            [                                
                                Stats.getChartSeries("rgba(145, 215, 255, 0.8)"),
                                Stats.getChartSeries("rgba( 90, 160, 200, 1.0)"),
                                Stats.getChartSeries("rgba(135,  70, 135, 0.7)"),
                                Stats.getChartSeries("rgba(210, 160,   0, 1.0)"),
                                Stats.getChartSeries("rgba(100, 250, 100, 0.7)"),
                                Stats.getChartSeries("rgba( 50, 170,  50, 1.0)")
                            ],
                            legend:
                            {
                                show:true,
                                location: "nw",
                                labels: ["Organizations", "Spaces", "Users", "Apps", "Total Instances", "Running Instances"],
                                renderer: $.jqplot.EnhancedLegendRenderer
                            },
                            highlighter:
                            {
                                show: true,
                                sizeAdjust: 7.5
                            },
                            cursor: 
                            {
                                show: false
                            }
                        });
    },

    getChartSeries: function(rgba)
    {
        var series = {
                         lineWidth: 3, 
                         showMarker: false,
                         rendererOptions:
                         {
                             animation:
                             {                                
                                 speed: 2000 // Default is 3000
                             }
                         }
                     };

        if (rgba != null)
        {
            series.color = rgba;
        }

        return series;
    },

    hideChartSeries: function(chartID, seriesIndices)
    {
        var legend = $("#" + chartID).children(".jqplot-table-legend");

        var legendItems = $(legend).find("td.jqplot-seriesToggle");

        var num = seriesIndices.length;

        for (var seriesIndex = 0; seriesIndex < num; seriesIndex++)
        {
            var legendIndex = seriesIndices[seriesIndex] * 2;

            var legendItem = legendItems[legendIndex];

            if (document.createEvent) 
            {
                var evt = document.createEvent("HTMLEvents");
                evt.initEvent("click", true, true);
                legendItem.dispatchEvent(evt);
            }
            else
            {      
                var evt = document.createEventObject();
                legendItem.fireEvent("onclick", evt);
            }
        }
    },
};

