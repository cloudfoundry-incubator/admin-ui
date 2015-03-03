
function CloudControllersTab(id)
{
    Tab.call(this, id, Constants.URL__CLOUD_CONTROLLERS_VIEW_MODEL);
}

CloudControllersTab.prototype = new Tab();

CloudControllersTab.prototype.constructor = CloudControllersTab;

CloudControllersTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

CloudControllersTab.prototype.getColumns = function()
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
               }
           ];
};

CloudControllersTab.prototype.clickHandler = function()
{
    this.itemClicked(2, 0);
};

CloudControllersTab.prototype.showDetails = function(table, cloudController, row)
{
    var data = cloudController.data;
    
    this.addPropertyRow(table, "Name",             cloudController.name, true);
    this.addPropertyRow(table, "Index",            Format.formatNumber(cloudController.index));
    this.addLinkRow(table,     "URI",              cloudController);
    this.addPropertyRow(table, "Started",          Format.formatDateString(data.start));
    this.addPropertyRow(table, "Uptime",           Format.formatUptime(data.uptime));
    this.addPropertyRow(table, "Cores",            Format.formatNumber(data.num_cores));
    this.addPropertyRow(table, "CPU",              Format.formatNumber(data.cpu));
    this.addPropertyRow(table, "Memory",           Format.formatNumber(row[6]));
    this.addPropertyRow(table, "Requests",         Format.formatNumber(data.vcap_sinatra.requests.completed));
    this.addPropertyRow(table, "Pending Requests", Format.formatNumber(data.vcap_sinatra.requests.outstanding));
};
