
function RoutersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ROUTERS, Constants.URL__ROUTERS_VIEW_MODEL);
}

RoutersTab.prototype = new Tab();

RoutersTab.prototype.constructor = RoutersTab;

RoutersTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.top10AppsTable = Table.createTable("RoutersTop10Applications", this.getTop10AppsColumns(), [[2, "desc"]], null, null, Constants.FILENAME__ROUTER_APPLICATIONS, null, null);
};

RoutersTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

RoutersTab.prototype.getColumns = function()
{
    return [
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Index",
                   width:  "300px",
                   render: Format.formatString
               },
               {
                   title:  "Source",
                   width:  "80px",
                   render: Format.formatString
               },
               {
                   title:  "Metrics",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "State",
                   width:  "80px",
                   render: function(value, type, item)
                           {
                               if (item[2] == "doppler")
                               {
                                   return Format.formatDopplerStatus(value, type, item);
                               }
                               else
                               {
                                   return Format.formatStatus(value, type, item);
                               }
                           }
               },
               {
                   title:  "Started",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:     "Cores",
                   width:     "60px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "CPU",
                   width:     "60px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Memory",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Droplets",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Requests",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Bad Requests",
                   width:     "110px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               }
           ];
};

RoutersTab.prototype.getTop10AppsColumns = function()
{
    return [
               {
                   title:  "Name",
                   width:  "150px",
                   render: function(name, type, row)
                           {
                               var appName = Format.formatApplicationName(name, type);

                               if (Format.doFormatting(type))
                               {
                                   return "<a class='tableLink' onclick='AdminUI.showApplications(\"" +
                                          row[1] +
                                          "\")'>" +
                                          appName +
                                          "</a>";
                               }

                               return appName;
                           }
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:     "RPM",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "RPS",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Target",
                   width:  "200px",
                   render: Format.formatTarget
               },
           ];
};

RoutersTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#RoutersTop10ApplicationsTableContainer").hide();
};

RoutersTab.prototype.clickHandler = function()
{
    this.itemClicked(4, 0);
};

RoutersTab.prototype.showDetails = function(table, objects, row)
{
    var dopplerGoRouter = objects.doppler_gorouter;
    var varzRouter      = objects.varz_router;

    if (varzRouter != null)
    {
        var data        = varzRouter.data;
        var top10Apps   = objects.top_10_apps;

        this.addPropertyRow(table, "Name",          varzRouter.name, true);
        this.addPropertyRow(table, "Index",         Format.formatString(row[1]));
        this.addPropertyRow(table, "Source",        Format.formatString(row[2]));
        this.addLinkRow(table,     "URI",           varzRouter);
        this.addPropertyRow(table, "Started",       Format.formatDateString(data.start));
        this.addPropertyRow(table, "Uptime",        Format.formatUptime(data.uptime));
        this.addPropertyRow(table, "Cores",         Format.formatNumber(data.num_cores));
        this.addPropertyRow(table, "CPU",           Format.formatNumber(data.cpu));
        this.addPropertyRow(table, "Memory",        Format.formatNumber(row[8]));
        this.addPropertyRow(table, "Droplets",      Format.formatNumber(data.droplets));
        this.addPropertyRow(table, "Requests",      Format.formatNumber(data.requests));
        this.addPropertyRow(table, "Bad Requests",  Format.formatNumber(data.bad_requests));
        this.addPropertyRow(table, "2XX Responses", Format.formatNumber(data.responses_2xx));
        this.addPropertyRow(table, "3XX Responses", Format.formatNumber(data.responses_3xx));
        this.addPropertyRow(table, "4XX Responses", Format.formatNumber(data.responses_4xx));
        this.addPropertyRow(table, "5XX Responses", Format.formatNumber(varzRouter.data.responses_5xx));
        this.addPropertyRow(table, "XXX Responses", Format.formatNumber(varzRouter.data.responses_xxx));

        if ((top10Apps != null) && (top10Apps.length > 0))
        {
            // Have to show the table prior to populating for its sizing to work correctly.
            $("#RoutersTop10ApplicationsTableContainer").show();

            var top10AppsTableData = [];

            for (var top10AppsIndex = 0; top10AppsIndex < top10Apps.length; top10AppsIndex++)
            {
                var top10App = top10Apps[top10AppsIndex];

                var top10AppRow = [];

                top10AppRow.push(top10App.name);
                top10AppRow.push(top10App.guid);
                top10AppRow.push(top10App.rpm);
                top10AppRow.push(top10App.rps);
                top10AppRow.push(top10App.target);

                top10AppsTableData.push(top10AppRow);
            }

            this.top10AppsTable.api().clear().rows.add(top10AppsTableData).draw();
        }
    }
    else if (dopplerGoRouter != null)
    {
        this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[0]), dopplerGoRouter, true);
        this.addPropertyRow(table, "IP", Format.formatString(dopplerGoRouter.ip));
        this.addPropertyRow(table, "Index", Format.formatString(dopplerGoRouter.index));
        this.addPropertyRow(table, "Source", Format.formatString(row[2]));
        this.addPropertyRow(table, "Metrics", Format.formatDateString(row[3]));
        this.addRowIfValue(this.addPropertyRow, table, "Uptime",  Format.formatDopplerUptime, dopplerGoRouter.uptime);
        this.addRowIfValue(this.addPropertyRow, table, "Cores", Format.formatNumber, row[6]);
        this.addRowIfValue(this.addPropertyRow, table, "Memory", Format.formatNumber, row[8]);
    }
};
