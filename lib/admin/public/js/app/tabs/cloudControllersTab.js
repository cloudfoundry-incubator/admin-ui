
function CloudControllersTab(id)
{
    this.url = Constants.URL__CLOUD_CONTROLLERS;

    Tab.call(this, id);
}

CloudControllersTab.prototype = new Tab();

CloudControllersTab.prototype.constructor = CloudControllersTab;

CloudControllersTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px"
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
                   "sTitle":  "Memory",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
}

CloudControllersTab.prototype.updateTableRow = function(row, cloudController)
{
    row.push(cloudController.name);

    if (cloudController.connected)
    {
        row.push(cloudController.data.index);
        row.push(Constants.STATUS__RUNNING);
        row.push(cloudController.data.start);
        row.push(cloudController.data.num_cores);
        row.push(cloudController.data.cpu);

        // Conditional logic since mem becomes mem_bytes in 157
        if (cloudController.data.mem != null) 
        {  
          row.push(cloudController.data.mem);
        }
        else if (cloudController.data.mem_bytes != null)
        {
          row.push(cloudController.data.mem_bytes);
        }
        else
        {
          Utilities.addEmptyElementsToArray(row, 1);
        }

        row.push(cloudController);
    }
    else
    {
        Utilities.addEmptyElementsToArray(row, 1);
        row.push(Constants.STATUS__OFFLINE);
        row.push(cloudController.data.start != null ? cloudController.data.start : "");

        Utilities.addEmptyElementsToArray(row, 4);

        row.push(cloudController.uri);
    }
}

CloudControllersTab.prototype.clickHandler = function()
{
    this.itemClicked(7, false);
}

CloudControllersTab.prototype.showDetails = function(table, cloudController, row)
{
    this.addPropertyRow(table, "Name",             cloudController.name, true);
    this.addPropertyRow(table, "Index",            Format.formatNumber(cloudController.data.index));
    this.addLinkRow(table,     "URI",              cloudController);
    this.addPropertyRow(table, "Started",          Format.formatDateString(cloudController.data.start));
    this.addPropertyRow(table, "Uptime",           Format.formatUptime(cloudController.data.uptime));
    this.addPropertyRow(table, "Cores",            Format.formatNumber(cloudController.data.num_cores));
    this.addPropertyRow(table, "CPU",              Format.formatNumber(cloudController.data.cpu));
    this.addPropertyRow(table, "Memory",           Format.formatNumber(row[6]));
    this.addPropertyRow(table, "Requests",         Format.formatNumber(cloudController.data.vcap_sinatra.requests.completed));
    this.addPropertyRow(table, "Pending Requests", Format.formatNumber(cloudController.data.vcap_sinatra.requests.outstanding));
}

