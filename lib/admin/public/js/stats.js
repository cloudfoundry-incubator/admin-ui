
$(document).ready(function()
{
    Statistics.startup();
});

var Statistics =
{
    startup: function()
    {
        var deferred = $.ajax({
                                  url: "statistics",
                                  dataType: "json",
                                  type: "GET"
                              });

        deferred.done(function(response, status)
        {            
            Statistics.data = response;

            Statistics.initialize();
        });

        deferred.fail(function(xhr, status, error)
        {
            window.location.href = "login.html";
        });        
    },

    initialize: function()
    {
        $(window).resize(this.resize);

        $("#Label").text(this.data.label);

        var config = {
                         "sPaginationType": "full_numbers",
                         "aLengthMenu": [[5, 10, 25, 50, 100, -1], [5, 10, 25, 50, 100, "All"]],
                         "iDisplayLength": 100,
                         "sScrollY": "219px",
                         "bScrollCollapse": true,
                         "sDom": 'T<"clear">lfrtip',
                         "bAutoWidth": false,
                         "aaSorting": [[0, "desc"]],
                         "oTableTools": {
                                            "aButtons": [],
                                            "sRowSelect": "none"
                                        }
                     };

        config["aoColumns"] = [
                                  {
                                      "sTitle":  "Date",
                                      "sWidth":  "170px",
                                      "mRender": Utilities.formatDateNumber
                                  },
                                  {
                                      "sTitle":  "Users",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "sType":   "formatted-num",
                                      "mRender": Utilities.formatNumber
                                  },
                                  {
                                      "sTitle":  "Apps",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "sType":   "formatted-num",
                                      "mRender": Utilities.formatNumber
                                  },
                                  {
                                      "sTitle":  "Running",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "sType":   "formatted-num",
                                      "mRender": Utilities.formatNumber
                                  },
                                  {
                                      "sTitle":  "Total",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "sType":   "formatted-num",
                                      "mRender": Utilities.formatNumber
                                  },
                                  {
                                      "sTitle":  "DEAs",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "sType":   "formatted-num",
                                      "mRender": Utilities.formatNumber
                                  }
                              ];

        this.statisticsTable = $("#StatisticsTable").dataTable(config);

        Utilities.addClearFilterButton("StatisticsTableContainer", this.statisticsTable);

        var tableData = new Array();

        var items = this.data.items;

        for (var index in items)
        {
            var item = items[index];

            var row = new Array();    

            row.push(item.timestamp);
            row.push(item.users);
            row.push(item.apps);
            row.push(item.running_instances);
            row.push(item.total_instances);
            row.push(item.deas);
              
            tableData.push(row);
        }

        this.statisticsTable.fnAddData(tableData);


        var stats = Utilities.buildStatsData(items);

        this.chart = Utilities.createStatsChart("Chart", stats);


        document.body.style.visibility = "visible";


        this.resize();

        //Utilities.hideChartSeries("Chart", [1, 4]);
    },

    resize: function()
    {
        Statistics.statisticsTable.fnDraw();

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
            $("#Chart").width(maxWidth);
            $("#Chart").height(Math.max(tableHeight - 40, minChartHeight));
        }
        else
        {
            $("#Chart").width(tableWidth - 40);
            $("#Chart").height(Math.max(maxHeight, minChartHeight));
        }

        Statistics.chart.replot({resetAxes: true});
    }

};

