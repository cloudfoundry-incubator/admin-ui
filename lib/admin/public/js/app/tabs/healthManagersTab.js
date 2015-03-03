
function HealthManagersTab(id)
{
    Tab.call(this, id, Constants.URL__HEALTH_MANAGERS_VIEW_MODEL);
}

HealthManagersTab.prototype = new Tab();

HealthManagersTab.prototype.constructor = HealthManagersTab;

HealthManagersTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

HealthManagersTab.prototype.getColumns = function()
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
                   "sTitle":  "Users",
                   "sWidth":  "90px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Applications",
                   "sWidth":  "90px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Instances",
                   "sWidth":  "90px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
};

HealthManagersTab.prototype.clickHandler = function()
{
    this.itemClicked(2, 0);
};

HealthManagersTab.prototype.showDetails = function(table, healthManager, row)
{
    var data = healthManager.data;
    
    this.addPropertyRow(table, "Name",              healthManager.name, true);
    this.addPropertyRow(table, "Index",             Format.formatNumber(healthManager.index));
    this.addLinkRow(table,     "URI",               healthManager);
    this.addPropertyRow(table, "Started",           Format.formatDateString(data.start));
    this.addPropertyRow(table, "Uptime",            Format.formatUptime(data.uptime));
    this.addPropertyRow(table, "Cores",             Format.formatNumber(data.num_cores));
    this.addPropertyRow(table, "CPU",               Format.formatNumber(data.cpu));
    this.addPropertyRow(table, "Memory",            Format.formatNumber(row[6]));
    this.addPropertyRow(table, "Users",             Format.formatNumber(data.total_users));
    this.addPropertyRow(table, "Applications",      Format.formatNumber(data.total_apps));
    this.addPropertyRow(table, "Instances",         Format.formatNumber(data.total_instances));
    this.addPropertyRow(table, "Running Instances", Format.formatNumber(data.running_instances));
    this.addPropertyRow(table, "Crashed Instances", Format.formatNumber(data.crashed_instances));
};
