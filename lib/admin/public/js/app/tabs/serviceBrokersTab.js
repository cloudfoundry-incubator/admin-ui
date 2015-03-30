function ServiceBrokersTab(id) 
{
    Tab.call(this, id, Constants.URL__SERVICE_BROKERS_VIEW_MODEL);
}

ServiceBrokersTab.prototype = new Tab();

ServiceBrokersTab.prototype.constructor = ServiceBrokersTab;

ServiceBrokersTab.prototype.getInitialSort = function() 
{
    return [[0, "asc"]];
};

ServiceBrokersTab.prototype.getColumns = function() 
{
    return [
                {
                    "sTitle":  "Name",
                    "sWidth":  "200px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle":  "GUID",
                    "sWidth":  "200px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Created",
                    "sWidth":  "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Updated",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Services",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },
                {
                    "sTitle":  "Service Plans",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },
                {
                    "sTitle":  "Service Plan Visibilities",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },
                {
                    "sTitle":  "Service Instances",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },
                {
                    "sTitle":  "Service Bindings",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },

            ];
};

ServiceBrokersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

ServiceBrokersTab.prototype.showDetails = function(table, serviceBroker, row)
{
    this.addJSONDetailsLinkRow(table, "Service Broker Name", Format.formatString(serviceBroker.name), serviceBroker, true);
    this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
    this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    this.addPropertyRow(table, "Service Broker Auth Username", Format.formatString(serviceBroker.auth_username));
    this.addPropertyRow(table, "Service Broker Broker URL", Format.formatString(serviceBroker.broker_url));
    
    if (row[4] != null)
    {
        this.addFilterRow(table, "Services", Format.formatNumber(row[4]), serviceBroker.guid, AdminUI.showServices);
    }
    
    if (row[5] != null)
    {
        this.addFilterRow(table, "Service Plans", Format.formatNumber(row[5]), serviceBroker.guid, AdminUI.showServicePlans);
    }
    
    if (row[6] != null)
    {
        this.addFilterRow(table, "Service Plan Visibilities", Format.formatNumber(row[6]), serviceBroker.guid, AdminUI.showServicePlanVisibilities);
    }
    
    if (row[7] != null)
    {
        this.addFilterRow(table, "Service Instances", Format.formatNumber(row[7]), serviceBroker.guid, AdminUI.showServiceInstances);
    }
    
    if (row[8] != null)
    {
        this.addFilterRow(table, "Service Bindings", Format.formatNumber(row[8]), serviceBroker.guid, AdminUI.showServiceBindings);
    }
};
