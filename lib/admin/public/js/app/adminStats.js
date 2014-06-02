
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
                         "sPaginationType": "full_numbers",
                         "aLengthMenu": [[5, 10, 25, 50, 100, -1], [5, 10, 25, 50, 100, "All"]],
                         "iDisplayLength": 100,
                         "sScrollY": "219px",
                         "bScrollCollapse": true,
                         "sDom": 'T<"clear">lfrtip',
                         "bAutoWidth": false,
                         "aaSorting": [[0, "desc"]],
                         "oTableTools": {
                                            "sSwfPath": "js/external/jquery/TableTools-2.1.5/media/swf/copy_csv_xls_pdf.swf",
                                            "sRowSelect": "none",
                                            "aButtons": [
                                                            {
                                                                "sExtends": "copy",
                                                                "fnClick": function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, "Statistics"); }
                                                            },
                                                            "print",
                                                            {
                                                                "sExtends":    "collection",
                                                                "sButtonText": "Save",
                                                                "aButtons":    [
                                                                                   {
                                                                                       "sExtends": "csv",
                                                                                       "fnClick": function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, "Statistics"); }
                                                                                   },
                                                                                   {
                                                                                       "sExtends": "xls",
                                                                                       "fnClick": function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, "Statistics"); }
                                                                                   },
                                                                                   {
                                                                                       "sExtends": "pdf",
                                                                                       "fnClick": function(nButton, oConfig, flash) { Table.rawPDF(nButton, oConfig, flash, "Statistics"); }
                                                                                   }
                                                                               ]
                                                            }
                                                        ]
                                        }
                     };
        
        config.bServerSide   = true;
        config.bProcessing   = true;
        config.sAjaxDataProp = "items";
        config.sAjaxSource   = Constants.URL__STATS_VIEW_MODEL;
        config.sServerMethod = "GET";
        config.fnServerData  = function(sSource, aoData, fnCallback, oSettings) 
        {
            var deferred = $.ajax({ 
                                      "dataType": 'json',
                                      "type": "GET",
                                      "url": sSource,
                                      "async": false, // This needs to be sync or we cannot know when to reset selection after fnDraw.
                                      "data": aoData
                                 });
            
            deferred.done(function(result, status)
            {            
                if (result.items.connected)
                {
                    oSettings.oLanguage.sEmptyTable = "No data available in table";
                }
                else
                {
                    oSettings.oLanguage.sEmptyTable = "Unable to retrieve data for table";

                    if (result.items.error)
                    {
                        oSettings.oLanguage.sEmptyTable += ".  Error: " + result.items.error;
                    }    
                }
                
                // We cannot get the label until the server-side results are available
                $("#Label").text(result.items.label);
                
                // Have to modify the items to get them to work since we want to return 
                // connected and items initially as children of outermost items, but jquery
                // just wants the leaf items array.
                //alert(JSON.stringify(result));
                result.items = result.items.items;
                
                fnCallback(result, status);
            });
            
            deferred.fail(function(xhr, status, error)
            {
                oSettings.oLanguage.sEmptyTable = "Unable to retrieve data for table.  Error: " + error;
                
                fnCallback({iTotalRecords:0, iTotalDisplayRecords:0, items:[]}, status);
            });
          };

        config["aoColumns"] = [
                                  {
                                      "sTitle":  "Date",
                                      "sWidth":  "170px",
                                      "mRender": Format.formatString
                                  },
                                  {
                                      "sTitle":  "Organizations",
                                      "sWidth":  "110px",
                                      "sClass":  "cellRightAlign",
                                      "mRender": Format.formatNumber
                                  },
                                  {
                                      "sTitle":  "Spaces",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "mRender": Format.formatNumber
                                  },
                                  {
                                      "sTitle":  "Users",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "mRender": Format.formatNumber
                                  },
                                  {
                                      "sTitle":  "Apps",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "mRender": Format.formatNumber
                                  },
                                  {
                                      "sTitle":  "Total",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "mRender": Format.formatNumber
                                  },
                                  {
                                      "sTitle":  "Running",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "mRender": Format.formatNumber
                                  },
                                  {
                                      "sTitle":  "DEAs",
                                      "sWidth":  "80px",
                                      "sClass":  "cellRightAlign",
                                      "mRender": Format.formatNumber
                                  }
                              ];

        this.statisticsTable = $("#StatisticsTable").dataTable(config);

        Table.addClearFilterButton("StatisticsTableContainer", this.statisticsTable);

        var rows   = this.statisticsTable.fnGetData();
        var stats  = Stats.buildStatsData(rows);
        this.chart = Stats.createStatsChart("StatisticsChart", stats);

        document.body.style.visibility = "visible";

        this.resize();
    },

    resize: function()
    {
        AdminStats.statisticsTable.fnDraw();

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

        AdminStats.chart.replot({resetAxes: true});
    }
};

