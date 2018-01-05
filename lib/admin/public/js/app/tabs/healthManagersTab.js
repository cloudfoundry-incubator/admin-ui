
function HealthManagersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__HEALTH_MANAGERS, Constants.URL__HEALTH_MANAGERS_VIEW_MODEL);
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
                   title:     "Cores",
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
           ];
};

HealthManagersTab.prototype.clickHandler = function()
{
    this.itemClicked(4, 0);
};

HealthManagersTab.prototype.showDetails = function(table, dopplerAnalyzer, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[0]), dopplerAnalyzer, true);
    this.addPropertyRow(table, "IP", Format.formatString(dopplerAnalyzer.ip));
    this.addPropertyRow(table, "Index", Format.formatString(dopplerAnalyzer.index));
    this.addPropertyRow(table, "Source", Format.formatString(row[2]));
    this.addPropertyRow(table, "Metrics", Format.formatDateString(row[3]));
    this.addRowIfValue(this.addPropertyRow, table, "Cores", Format.formatNumber, row[5]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory", Format.formatNumber, row[6]);
    this.addRowIfValue(this.addPropertyRow, table, "Desired Apps", Format.formatNumber, dopplerAnalyzer.NumberOfDesiredApps);
    this.addRowIfValue(this.addPropertyRow, table, "Desired Apps Pending Staging", Format.formatNumber, dopplerAnalyzer.NumberOfDesiredAppsPendingStaging);
    this.addRowIfValue(this.addPropertyRow, table, "Undesired Running Apps", Format.formatNumber, dopplerAnalyzer.NumberOfUndesiredRunningApps);
    this.addRowIfValue(this.addPropertyRow, table, "Apps With All Instances Reporting", Format.formatNumber, dopplerAnalyzer.NumberOfAppsWithAllInstancesReporting);
    this.addRowIfValue(this.addPropertyRow, table, "Apps With Missing Instances", Format.formatNumber, dopplerAnalyzer.NumberOfAppsWithMissingInstances);
    this.addRowIfValue(this.addPropertyRow, table, "Desired Instances", Format.formatNumber, dopplerAnalyzer.NumberOfDesiredInstances);
    this.addRowIfValue(this.addPropertyRow, table, "Running Instances", Format.formatNumber, dopplerAnalyzer.NumberOfRunningInstances);
    this.addRowIfValue(this.addPropertyRow, table, "Crashed Instances", Format.formatNumber, dopplerAnalyzer.NumberOfCrashedInstances);
};
