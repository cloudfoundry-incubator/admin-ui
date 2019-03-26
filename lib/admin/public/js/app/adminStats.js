
$(document).ready(function()
{
    AdminStats.startup();
});

var AdminStats =
{
    startup: function()
    {
        AdminStats.initialize();
    },

    initialize: function()
    {
        $(window).resize(this.resize);

        var config = {
                         autoWidth:      false,
                         buttons:        [
                                             "copy",
                                             "print",
                                             {
                                                 extend:    "collection",
                                                 text:      "Save",
                                                 autoClose: true,
                                                 buttons:
                                                 [
                                                     { extend: "csv",   filename: Constants.FILENAME__STATS },
                                                     { extend: "excel", filename: Constants.FILENAME__STATS },
                                                     { extend: "pdf",   filename: Constants.FILENAME__STATS, orientation: "landscape" }
                                                 ]
                                             }
                                         ],
                         dom:            "lfBtipr",
                         lengthMenu:     [[5, 10, 25, 50, 100, -1], [5, 10, 25, 50, 100, "All"]],
                         order:          [[0, "desc"]],
                         pageLength:     10,
                         pagingType:     "full_numbers",
                         scrollCollapse: true,
                         scrollY:        "219px",
                     };

        var afterServerDataCallback = $.proxy(function()
                                              {
                                                  var rows  = this.statisticsTable.api().rows().data();
                                                  var stats = Stats.buildStatsData(rows);

                                                  this.chart = Stats.createStatsChart("StatisticsChart", stats);

                                                  this.resize();
                                              },
                                              this);

        config.deferLoading = 0;
        config.processing   = true;
        config.serverSide   = true;
        config.ajax         = function(data, callback, settings)
        {
            var deferred = $.ajax({
                                      dataType: "json",
                                      type:     "GET",
                                      url:      Constants.URL__STATS_VIEW_MODEL,
                                      async:    false, // This needs to be sync or we cannot know when to reset selection after draw.
                                      data:     data
                                  });

            deferred.done(function(result, status)
                          {
                              if (result.items.connected)
                              {
                                  settings.oLanguage.sEmptyTable = "No data available in table";
                              }
                              else
                              {
                                  settings.oLanguage.sEmptyTable = "Unable to retrieve data for table";

                                  if (result.items.error)
                                  {
                                      settings.oLanguage.sEmptyTable += ". Error: " + result.items.error;
                                  }
                              }

                              // We cannot get the label until the server-side results are available
                              $("#Label").text(result.items.label);
                              $("#Build").text("Build " + result.items.build);

                              // Have to modify the items to get them to work since we want to return
                              // connected and items initially as children of outermost items for use here, but jquery
                              // just wants the leaf items array and with the name data.
                              result.data = result.items.items;
                              callback(result);

                              // We need to know when new server data has been fetched so it can redraw its graph
                              afterServerDataCallback();
                          });

            deferred.fail(function(xhr, status, error)
                          {
                              settings.oLanguage.sEmptyTable = "Unable to retrieve data for table";

                              if (error)
                              {
                                  settings.oLanguage.sEmptyTable += ". Error: " + error;
                              }

                              // Have to make the callback or the table processing message won't terminate
                              callback({
                                           draw:            data.draw,
                                           recordsTotal:    0,
                                           recordsFiltered: 0, 
                                           data:            []
                              });

                              // We need to know when new server data has been fetched so it can redraw its graph
                              afterServerDataCallback();
                          });
        };

        config["columns"] = [
                                {
                                    title:  "Date",
                                    width:  "170px",
                                    render: Format.formatString
                                },
                                {
                                    title:     "Organizations",
                                    width:     "110px",
                                    className: "cellRightAlign",
                                    render:    Format.formatNumber
                                },
                                {
                                    title:     "Spaces",
                                    width:     "80px",
                                    className: "cellRightAlign",
                                    render:    Format.formatNumber
                                },
                                {
                                    title:     "Users",
                                    width:     "80px",
                                    className: "cellRightAlign",
                                    render:    Format.formatNumber
                                },
                                {
                                    title:     "Apps",
                                    width:     "80px",
                                    className: "cellRightAlign",
                                    render:    Format.formatNumber
                                },
                                {
                                    title:     "Total",
                                    width:     "80px",
                                    className: "cellRightAlign",
                                    render:    Format.formatNumber
                                },
                                {
                                    title:     "Running",
                                    width:     "80px",
                                    className: "cellRightAlign",
                                    render:    Format.formatNumber
                                },
                                {
                                    title:     "DEAs",
                                    width:     "80px",
                                    className: "cellRightAlign",
                                    render:    Format.formatNumber
                                },
                                {
                                    title:     "Cells",
                                    width:     "80px",
                                    className: "cellRightAlign",
                                    render:    Format.formatNumber
                                }
                            ];

        this.statisticsTable = $("#StatisticsTable").dataTable(config);

        var api = this.statisticsTable.api();

        Table.wrapRawButtons(api);

        // Use plugin to cause second delay when entering in search field
        this.statisticsTable.fnSetFilteringDelay(1000);

        Table.addClearFilterButton("StatisticsTableContainer", this.statisticsTable);

        document.body.style.visibility = "visible";

        api.draw();
    },

    resize: function()
    {
        var windowHeight = $(window).height();
        var windowWidth  = $(window).width();

        var tablePosition = $("#StatisticsTableContainer").position();
        var tableHeight   = $("#StatisticsTableContainer").outerHeight(true);
        var tableWidth    = $("#StatisticsTableContainer").outerWidth(true);

        var maxHeight = windowHeight - tablePosition.top  - tableHeight - 50;
        var maxWidth  = windowWidth  - tablePosition.left - tableWidth  - 60;

        var minChartWidth  = 500;
        var minChartHeight = 260;

        if (windowWidth > (tableWidth + minChartWidth))
        {
            $("#StatisticsChart").width(maxWidth);
            $("#StatisticsChart").height(Math.max(tableHeight - 40, minChartHeight));
        }
        else
        {
            $("#StatisticsChart").width(tableWidth - 40);
            $("#StatisticsChart").height(Math.max(maxHeight, minChartHeight));
        }

        AdminStats.chart.replot({
                                    resetAxes: true
                                });
    }
};
