
function RoutersTab(id)
{
    Tab.call(this, id, Constants.URL__ROUTERS_VIEW_MODEL);
}

RoutersTab.prototype = new Tab();

RoutersTab.prototype.constructor = RoutersTab;

RoutersTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.top10AppsTable = Table.createTable("RoutersTop10Applications", this.getTop10AppsColumns(), [[1, "desc"]], null, null, null, null);
};

RoutersTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

RoutersTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Index",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Cores",
                   "sWidth":  "60px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "CPU",
                   "sWidth":  "60px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Memory",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Droplets",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Requests",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Bad Requests",
                   "sWidth":  "110px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
};

RoutersTab.prototype.getTop10AppsColumns = function()
{
    return [
               {
                   "sTitle": "Name",
                   "sWidth": "150px",
                   "mRender": Format.formatApplicationName
               },
               {
                   "sTitle":  "RPM",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "RPS",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "200px",
                   "mRender": function(name, type)
                   {
                       if (Format.doFormatting(type))
                       {
                           cleansedName = Format.formatStringCleansed(name);
                           return "<a class='tableLink' onclick='AdminUI.showSpaces(\"" + 
                                  cleansedName + 
                                  "\")'>" + 
                                  cleansedName + 
                                  "</a>"; 
                       }

                       return name;
                   }
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
    this.itemClicked(2, 0);
};

RoutersTab.prototype.showDetails = function(table, objects, row)
{
    router    = objects.router;
    top10Apps = objects.top10Apps;
    
    this.addPropertyRow(table, "Name",          router.name, true);
    this.addPropertyRow(table, "Index",         Format.formatNumber(router.data.index));
    this.addLinkRow(table,     "URI",           router);
    this.addPropertyRow(table, "Started",       Format.formatDateString(router.data.start));
    this.addPropertyRow(table, "Uptime",        Format.formatUptime(router.data.uptime));
    this.addPropertyRow(table, "Cores",         Format.formatNumber(router.data.num_cores));
    this.addPropertyRow(table, "CPU",           Format.formatNumber(router.data.cpu));
    this.addPropertyRow(table, "Memory",        Format.formatNumber(row[6]));
    this.addPropertyRow(table, "Droplets",      Format.formatNumber(router.data.droplets));
    this.addPropertyRow(table, "Requests",      Format.formatNumber(router.data.requests));
    this.addPropertyRow(table, "Bad Requests",  Format.formatNumber(router.data.bad_requests));
    this.addPropertyRow(table, "2XX Responses", Format.formatNumber(router.data.responses_2xx));
    this.addPropertyRow(table, "3XX Responses", Format.formatNumber(router.data.responses_3xx));
    this.addPropertyRow(table, "4XX Responses", Format.formatNumber(router.data.responses_4xx));
    this.addPropertyRow(table, "5XX Responses", Format.formatNumber(router.data.responses_5xx));
    this.addPropertyRow(table, "XXX Responses", Format.formatNumber(router.data.responses_xxx));
    
    if (top10Apps != null && top10Apps.length > 0)
    {
        // Have to show the table prior to populating for its sizing to work correctly.
        $("#RoutersTop10ApplicationsTableContainer").show();

        var top10AppsTableData = [];

        for (var top10AppsIndex = 0; top10AppsIndex < top10Apps.length; top10AppsIndex++)
        {
            var top10App = top10Apps[top10AppsIndex];

            var top10AppRow = [];

            top10AppRow.push(top10App.application);
            top10AppRow.push(top10App.rpm);
            top10AppRow.push(top10App.rps);
            top10AppRow.push(top10App.target);

            top10AppsTableData.push(top10AppRow);
        }

        this.top10AppsTable.fnClearTable();
        this.top10AppsTable.fnAddData(top10AppsTableData);
    }
};
