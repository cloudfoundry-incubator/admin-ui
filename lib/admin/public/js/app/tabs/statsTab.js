
function StatsTab(id)
{
    this.url = Constants.URL__STATS;

    Tab.call(this, id);
}

StatsTab.prototype = new Tab();

StatsTab.prototype.constructor = StatsTab;

StatsTab.prototype.initialize = function()
{
    this.table = Table.createTable(this.id, this.getColumns(), this.getInitialSort(), null, [{text: "Create Stats", click: AdminUI.createStatsConfirmation}]);
}

StatsTab.prototype.getInitialSort = function()
{
    return [[0, "desc"]];
}

StatsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Date",
                   "sWidth":  "170px",
                   "mRender": Format.formatDateNumber
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
}

StatsTab.prototype.refresh = function(reload)
{
    Data.get(this.url, reload).done($.proxy(function(result)
    {
        this.updateData([result], reload);

        this.buildStatsChart(result.response.items);
    },
    this));
}

StatsTab.prototype.buildStatsChart = function(items)
{
    var stats = Stats.buildStatsData(items);

    this.statsChart = Stats.createStatsChart("StatsChart", stats);

    this.resize();

    //Stats.hideChartSeries("StatsChart", [1, 4]);
}

StatsTab.prototype.updateTableRow = function(row, item)
{
    Stats.updateStatsTableRow(row, item);
}

StatsTab.prototype.buildCurrentStatsView = function(stats)
{
    var html = "The following stats will be added:<br/><br/>";

    html += "<span style='margin-left: 5px;'>" + Format.formatDateNumber(stats.timestamp) + "</span>";

    html += "<div style='background-color: rgb(235, 235, 235); border: 1px rgb(220, 220, 220) inset; padding: 10px; margin-top: 5px;'>";
    html += "  <table cellpadding='3'>";
    html += "    <tr style='border-bottom: 1px solid rgb(190, 190, 190);'>";
    html += "      <td>Organizations:</td>";
    html += "      <td class='cellRightAlign'>" + Format.formatNumber(stats.organizations) + "</td>";
    html += "    </tr>";
    html += "    <tr style='border-bottom: 1px solid rgb(190, 190, 190);'>";
    html += "      <td>Spaces:</td>";
    html += "      <td class='cellRightAlign'>" + Format.formatNumber(stats.spaces) + "</td>";
    html += "    </tr>";
    html += "    <tr style='border-bottom: 1px solid rgb(190, 190, 190);'>";
    html += "      <td>Users:</td>";
    html += "      <td class='cellRightAlign'>" + Format.formatNumber(stats.users) + "</td>";
    html += "    </tr>";
    html += "    <tr style='border-bottom: 1px solid rgb(190, 190, 190);'>";
    html += "      <td>Apps:</td>";
    html += "      <td class='cellRightAlign'>" + Format.formatNumber(stats.apps) + "</td>";
    html += "    </tr>";
    html += "    <tr style='border-bottom: 1px solid rgb(190, 190, 190);'>";
    html += "      <td>Total Instances:</td>";
    html += "      <td class='cellRightAlign'>" + Format.formatNumber(stats.total_instances) + "</td>";
    html += "    </tr>";
    html += "    <tr style='border-bottom: 1px solid rgb(190, 190, 190);'>";
    html += "      <td>Running Instances:</td>";
    html += "      <td class='cellRightAlign'>" + Format.formatNumber(stats.running_instances) + "</td>";
    html += "    </tr>";
    html += "    <tr>";
    html += "      <td>DEAs:</td>";
    html += "      <td class='cellRightAlign'>" + Format.formatNumber(stats.deas) + "</td>";
    html += "    </tr>";
    html += "  </table>"; 
    html += "</div>";

    return html;
}

StatsTab.prototype.resize = function()
{
    var windowHeight = $(window).height();
    var windowWidth  = $(window).width();

    var tablePosition = $("#StatsTableContainer").position();
    var tableHeight   = $("#StatsTableContainer").outerHeight(true);
    var tableWidth    = $("#StatsTableContainer").outerWidth(true);

    var maxHeight = windowHeight - tablePosition.top  - tableHeight - 50;        
    var maxWidth  = windowWidth  - tablePosition.left - tableWidth  - 50;        

    var minChartWidth  = 500;
    var minChartHeight = 260;

    if (windowWidth > (tableWidth + tablePosition.left + minChartWidth))
    {
        $("#StatsChart").width(maxWidth);
        $("#StatsChart").height(Math.max(tableHeight - 40, minChartHeight));
    }
    else
    {
        $("#StatsChart").width(tableWidth - 40);
        $("#StatsChart").height(Math.max(maxHeight, minChartHeight));
    }

    this.statsChart.replot({resetAxes: true});
}

