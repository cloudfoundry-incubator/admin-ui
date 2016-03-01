
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
                   "title":  "State",
                   "width":  "80px",
                   "render": Format.formatStatus
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
    this.itemClicked(2, 0);
};

HealthManagersTab.prototype.showDetails = function(table, healthManager, row)
{
    var data = healthManager.data;
    
    this.addPropertyRow(table, "Name",   healthManager.name, true);
    this.addPropertyRow(table, "Index",  Format.formatNumber(healthManager.index));
    this.addLinkRow(table,     "URI",    healthManager);
    this.addRowIfValue(this.addPropertyRow, table, "Cores", Format.formatNumber, data.numCPUS);
    
    if (data.memoryStats != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Memory", Format.formatNumber, data.memoryStats.numBytesAllocated);
    }
    
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
                    this.showMetric(table, metrics, "ActualStateListenerStoreUsagePercentage", "Actual State Listener Store Usage Percentage");
                    
                    this.showMetric(table, metrics, "NumberOfDesiredApps", "Desired Apps");
                    this.showMetric(table, metrics, "NumberOfDesiredAppsPendingStaging", "Desired Apps Pending Staging");
                    this.showMetric(table, metrics, "NumberOfUndesiredRunningApps", "Undesired Running Apps");
                    this.showMetric(table, metrics, "NumberOfAppsWithAllInstancesReporting", "Apps With All Instances Reporting");
                    this.showMetric(table, metrics, "NumberOfAppsWithMissingInstances", "Apps With Missing Instances");
                    this.showMetric(table, metrics, "NumberOfDesiredInstances", "Desired Instances");
                    this.showMetric(table, metrics, "NumberOfRunningInstances", "Running Instances");
                    this.showMetric(table, metrics, "NumberOfCrashedInstances", "Crashed Instances");

                    this.showMetric(table, metrics, "DesiredStateSyncTimeInMilliseconds", "Desired State Sync Time in Milliseconds");

                    /*
                    this.showMetric(table, metrics, "NumberOfCrashedIndices", "Crashed Indices");
                    this.showMetric(table, metrics, "NumberOfMissingIndices", "Missing Indices");
                    */
                    
                    this.showMetric(table, metrics, "ReceivedHeartbeats", "Received Heartbeats");
                    this.showMetric(table, metrics, "SavedHeartbeats", "Saved Heartbeats");
                    
                    this.showMetric(table, metrics, "StartCrashed", "Start Crashed");
                    this.showMetric(table, metrics, "StartEvacuating", "Start Evacuating");
                    this.showMetric(table, metrics, "StartMissing", "Start Missing");
                    
                    this.showMetric(table, metrics, "StopDuplicate", "Stop Duplicate");
                    this.showMetric(table, metrics, "StopExtra", "Stop Extra");
                    this.showMetric(table, metrics, "StopEvacuationComplete", "Stop Evacuation Complete");
                }   
                
                break;
            }
        }
    }    
};

HealthManagersTab.prototype.showMetric = function(table, metrics, key, label)
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
