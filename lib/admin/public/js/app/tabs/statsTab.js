
function StatsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__STATS, Constants.URL__STATS_VIEW_MODEL);
}

StatsTab.prototype = new Tab();

StatsTab.prototype.constructor = StatsTab;

StatsTab.prototype.initialize = function()
{
    this.table = Table.createTable(this.id, this.getColumns(), this.getInitialSort(), null, this.getActions(), this.filename, this.url, $.proxy(this.buildStatsChart, this));
};

StatsTab.prototype.getInitialSort = function()
{
    return [[0, "desc"]];
};

StatsTab.prototype.getColumns = function()
{
    return [
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
};

StatsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Create Stats",
                   click: AdminUI.createStatsConfirmation
               }
           ];
};

StatsTab.prototype.buildStatsChart = function()
{
    var rows  = this.table.api().rows().data();
    var stats = Stats.buildStatsData(rows);

    this.statsChart = Stats.createStatsChart("StatsChart", stats);

    this.resize();
};

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
    html += "    <tr style='border-bottom: 1px solid rgb(190, 190, 190);'>";
    html += "      <td>DEAs:</td>";
    html += "      <td class='cellRightAlign'>" + Format.formatNumber(stats.deas) + "</td>";
    html += "    </tr>";
    html += "    <tr>";
    html += "      <td>Cells:</td>";
    html += "      <td class='cellRightAlign'>" + Format.formatNumber(stats.cells) + "</td>";
    html += "    </tr>";
    html += "  </table>";
    html += "</div>";

    return html;
};

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

    this.statsChart.replot({ resetAxes: true });
};
