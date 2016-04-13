
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
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":     "Index",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Source",
                   "width":     "80px",
                   "render":    Format.formatString
               },
               {
                   "title":  "Metrics",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "State",
                   "width":  "80px",
                   "render": function(value, type, item)
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
                   "title":     "Cores",
                   "width":     "60px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Memory",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
           ];
};

HealthManagersTab.prototype.clickHandler = function()
{
    this.itemClicked(4, 0);
};

HealthManagersTab.prototype.showDetails = function(table, objects, row)
{
    var dopplerAnalyzer   = objects.doppler_analyzer;
    var varzHealthManager = objects.varz_health_manager;
    
    if (varzHealthManager != null)
    {
        var data = varzHealthManager.data;
        
        this.addPropertyRow(table, "Name",   varzHealthManager.name, true);
        this.addPropertyRow(table, "Index",  Format.formatNumber(varzHealthManager.index));
        this.addPropertyRow(table, "Source", Format.formatString(row[2]));
        this.addLinkRow(table,     "URI",    varzHealthManager);
        this.addRowIfValue(this.addPropertyRow, table, "Cores", Format.formatNumber, data.numCPUS);
        this.addRowIfValue(this.addPropertyRow, table, "Memory", Format.formatNumber, row[6]);
        
        if (data.contexts != null)
        {
            for (var contextsIndex = 0; contextsIndex < data.contexts.length; contextsIndex++)
            {
                var context = data.contexts[contextsIndex];
                
                if (context.name == "HM9000")
                {
                    var metrics = context.metrics;
                    
                    if (metrics != null)
                    {
                        this.showVarzMetric(table, metrics, "ActualStateListenerStoreUsagePercentage", "Actual State Listener Store Usage Percentage");
                        
                        this.showVarzMetric(table, metrics, "NumberOfDesiredApps", "Desired Apps");
                        this.showVarzMetric(table, metrics, "NumberOfDesiredAppsPendingStaging", "Desired Apps Pending Staging");
                        this.showVarzMetric(table, metrics, "NumberOfUndesiredRunningApps", "Undesired Running Apps");
                        this.showVarzMetric(table, metrics, "NumberOfAppsWithAllInstancesReporting", "Apps With All Instances Reporting");
                        this.showVarzMetric(table, metrics, "NumberOfAppsWithMissingInstances", "Apps With Missing Instances");
                        this.showVarzMetric(table, metrics, "NumberOfDesiredInstances", "Desired Instances");
                        this.showVarzMetric(table, metrics, "NumberOfRunningInstances", "Running Instances");
                        this.showVarzMetric(table, metrics, "NumberOfCrashedInstances", "Crashed Instances");
    
                        this.showVarzMetric(table, metrics, "DesiredStateSyncTimeInMilliseconds", "Desired State Sync Time in Milliseconds");
    
                        /*
                        this.showVarzMetric(table, metrics, "NumberOfCrashedIndices", "Crashed Indices");
                        this.showVarzMetric(table, metrics, "NumberOfMissingIndices", "Missing Indices");
                        */
                        
                        this.showVarzMetric(table, metrics, "ReceivedHeartbeats", "Received Heartbeats");
                        this.showVarzMetric(table, metrics, "SavedHeartbeats", "Saved Heartbeats");
                        
                        this.showVarzMetric(table, metrics, "StartCrashed", "Start Crashed");
                        this.showVarzMetric(table, metrics, "StartEvacuating", "Start Evacuating");
                        this.showVarzMetric(table, metrics, "StartMissing", "Start Missing");
                        
                        this.showVarzMetric(table, metrics, "StopDuplicate", "Stop Duplicate");
                        this.showVarzMetric(table, metrics, "StopExtra", "Stop Extra");
                        this.showVarzMetric(table, metrics, "StopEvacuationComplete", "Stop Evacuation Complete");
                    }   
                    
                    break;
                }
            }
        }    
    }
    else if (dopplerAnalyzer != null)
    {
        this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[0]), dopplerAnalyzer, true);
        this.addPropertyRow(table, "IP", Format.formatString(dopplerAnalyzer.ip));
        this.addPropertyRow(table, "Index", Format.formatNumber(dopplerAnalyzer.index));
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
    }
};

HealthManagersTab.prototype.showVarzMetric = function(table, metrics, key, label)
{
    for (var metricIndex = 0; metricIndex < metrics.length; metricIndex++)
    {
        var metric = metrics[metricIndex];
        
        if (key == metric.name)
        {
            this.addPropertyRow(table, label,  Format.formatNumber(metric.value));
            
            break;
        }
    }
};
