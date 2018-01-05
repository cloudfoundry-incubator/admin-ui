
function CloudControllersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__CLOUD_CONTROLLERS, Constants.URL__CLOUD_CONTROLLERS_VIEW_MODEL);
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
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:     "Index",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Source",
                   width:  "80px",
                   render: Format.formatString
               },
               {
                   title:  "State",
                   width:  "80px",
                   render: Format.formatStatus
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
               }
           ];
};

CloudControllersTab.prototype.clickHandler = function()
{
    this.itemClicked(3, 0);
};

CloudControllersTab.prototype.showDetails = function(table, cloudController, row)
{
    var data = cloudController.data;

    this.addPropertyRow(table, "Name",             cloudController.name, true);
    this.addPropertyRow(table, "Index",            Format.formatNumber(cloudController.index));
    this.addPropertyRow(table, "Source",           Format.formatString(row[2]));
    this.addLinkRow(table,     "URI",              cloudController);
    this.addPropertyRow(table, "Started",          Format.formatDateString(data.start));
    this.addPropertyRow(table, "Uptime",           Format.formatUptime(data.uptime));
    this.addPropertyRow(table, "Cores",            Format.formatNumber(data.num_cores));
    this.addPropertyRow(table, "CPU",              Format.formatNumber(data.cpu));
    this.addPropertyRow(table, "Memory",           Format.formatNumber(row[7]));
    this.addPropertyRow(table, "Requests",         Format.formatNumber(data.vcap_sinatra.requests.completed));
    this.addPropertyRow(table, "Pending Requests", Format.formatNumber(data.vcap_sinatra.requests.outstanding));
};
