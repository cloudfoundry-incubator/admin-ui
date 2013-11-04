
function RoutersTab(id)
{
    this.url = Constants.URL__ROUTERS;

    Tab.call(this, id);
}

RoutersTab.prototype = new Tab();

RoutersTab.prototype.constructor = RoutersTab;

RoutersTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px"
               },
               {
                   "sTitle":  "State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "180px",
                   "mRender": Format.formatDateString
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
                   "sTitle" :  "Memory",
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
}

RoutersTab.prototype.updateTableRow = function(row, router)
{
    row.push(router.name);

    if (router.connected)
    {
        row.push(Constants.STATUS__RUNNING);
        row.push(router.data.start);
        row.push(router.data.num_cores);
        row.push(router.data.cpu);
        row.push(router.data.mem);
        row.push(router.data.droplets);
        row.push(router.data.requests);
        row.push(router.data.bad_requests);

        row.push(router);
    }
    else
    {
        row.push(Constants.STATUS__OFFLINE);
        row.push(router.data.start != null ? router.data.start : "");

        Utilities.addEmptyElementsToArray(row, 7);

        row.push(router.uri);
    }
}

RoutersTab.prototype.clickHandler = function()
{
    this.itemClicked(9, false);
}

RoutersTab.prototype.showDetails = function(table, router, row)
{
    this.addPropertyRow(table, "Name",          router.name, true);
    this.addLinkRow(table,     "URI",           router);
    this.addPropertyRow(table, "Started",       Format.formatDateString(router.data.start));
    this.addPropertyRow(table, "Uptime",        Format.formatUptime(router.data.uptime));
    this.addPropertyRow(table, "Cores",         Format.formatNumber(router.data.num_cores));
    this.addPropertyRow(table, "CPU",           Format.formatNumber(router.data.cpu));
    this.addPropertyRow(table, "Memory",        Format.formatNumber(router.data.mem));
    this.addPropertyRow(table, "Droplets",      Format.formatNumber(router.data.droplets));
    this.addPropertyRow(table, "Requests",      Format.formatNumber(router.data.requests));
    this.addPropertyRow(table, "Bad Requests",  Format.formatNumber(router.data.bad_requests));
    this.addPropertyRow(table, "2XX Responses", Format.formatNumber(router.data.responses_2xx));
    this.addPropertyRow(table, "3XX Responses", Format.formatNumber(router.data.responses_3xx));
    this.addPropertyRow(table, "4XX Responses", Format.formatNumber(router.data.responses_4xx));
    this.addPropertyRow(table, "5XX Responses", Format.formatNumber(router.data.responses_5xx));
    this.addPropertyRow(table, "XXX Responses", Format.formatNumber(router.data.responses_xxx));
}

