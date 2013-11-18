
function HealthManagersTab(id)
{
    this.url = Constants.URL__HEALTH_MANAGERS;

    Tab.call(this, id);
}

HealthManagersTab.prototype = new Tab();

HealthManagersTab.prototype.constructor = HealthManagersTab;

HealthManagersTab.prototype.getColumns = function()
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
}

HealthManagersTab.prototype.updateTableRow = function(row, healthManager)
{
    row.push(healthManager.name);

    if (healthManager.connected)
    {
        row.push(Constants.STATUS__RUNNING);
        row.push(healthManager.data.start);
        row.push(healthManager.data.num_cores);
        row.push(healthManager.data.cpu);
        row.push(healthManager.data.mem);

        if (healthManager.data.total_users != null)
        {
            row.push(healthManager.data.total_users);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }
       
        if (healthManager.data.total_apps != null)
        {
            row.push(healthManager.data.total_apps);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        if (healthManager.data.total_instances != null)
        {
            row.push(healthManager.data.total_instances);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        row.push(healthManager);
    }
    else
    {
        row.push(Constants.STATUS__OFFLINE);
        row.push(healthManager.data.start != null ? healthManager.data.start : "");

        Utilities.addEmptyElementsToArray(row, 7);

        row.push(healthManager.uri);
    }
}

HealthManagersTab.prototype.clickHandler = function()
{
    this.itemClicked(9, false);
}

HealthManagersTab.prototype.showDetails = function(table, healthManager, row)
{
    this.addPropertyRow(table, "Name",              healthManager.name, true);
    this.addLinkRow(table,     "URI",               healthManager);
    this.addPropertyRow(table, "Started",           Format.formatDateString(healthManager.data.start));
    this.addPropertyRow(table, "Uptime",            Format.formatUptime(healthManager.data.uptime));
    this.addPropertyRow(table, "Cores",             Format.formatNumber(healthManager.data.num_cores));
    this.addPropertyRow(table, "CPU",               Format.formatNumber(healthManager.data.cpu));
    this.addPropertyRow(table, "Memory",            Format.formatNumber(healthManager.data.mem));
    this.addPropertyRow(table, "Users",             Format.formatNumber(healthManager.data.total_users));
    this.addPropertyRow(table, "Applications",      Format.formatNumber(healthManager.data.total_apps));
    this.addPropertyRow(table, "Instances",         Format.formatNumber(healthManager.data.total_instances));
    this.addPropertyRow(table, "Running Instances", Format.formatNumber(healthManager.data.running_instances));
    this.addPropertyRow(table, "Crashed Instances", Format.formatNumber(healthManager.data.crashed_instances));
}

