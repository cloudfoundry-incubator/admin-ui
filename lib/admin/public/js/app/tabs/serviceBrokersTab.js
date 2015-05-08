function ServiceBrokersTab(id) 
{
    Tab.call(this, id, Constants.URL__SERVICE_BROKERS_VIEW_MODEL);
}

ServiceBrokersTab.prototype = new Tab();

ServiceBrokersTab.prototype.constructor = ServiceBrokersTab;

ServiceBrokersTab.prototype.getInitialSort = function() 
{
    return [[1, "asc"]];
};

ServiceBrokersTab.prototype.getColumns = function() 
{
    return [
                {
                   "sTitle":    "&nbsp;",
                   "sWidth":    "2px",
                   "sClass":    "cellCenterAlign",
                   "bSortable": false,
                   "mRender":   function(value, type, item)
                   {
                       return Tab.prototype.formatCheckbox(item[1], value);
                   }
               },
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
                    "sTitle":  "Events",
                    "sWidth":  "70px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.formatNumber
                },
                {
                    "sTitle":  "Service Dashboard Client",
                    "sWidth":  "300px",
                    "mRender": Format.formatUserString
                },
                {
                    "sTitle":  "Services",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.formatNumber
                },
                {
                    "sTitle":  "Service Plans",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.formatNumber
                },
                {
                    "sTitle":  "Service Plan Visibilities",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.formatNumber
                },
                {
                    "sTitle":  "Service Instances",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.formatNumber
                },
                {
                    "sTitle":  "Service Bindings",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.formatNumber
                },
                {
                    "sTitle":  "Service Keys",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.formatNumber
                }
            ];
};

ServiceBrokersTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected service brokers?",
                                          "Delete",
                                          "Deleting Service Brokers",
                                          Constants.URL__SERVICE_BROKERS,
                                          "");
                   },
                   this)
               }
           ];
};

ServiceBrokersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServiceBrokersTab.prototype.showDetails = function(table, serviceBroker, row)
{
    this.addJSONDetailsLinkRow(table, "Service Broker Name", Format.formatString(serviceBroker.name), serviceBroker, true);
    this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
    this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    this.addPropertyRow(table, "Service Broker Auth Username", Format.formatString(serviceBroker.auth_username));
    this.addPropertyRow(table, "Service Broker Broker URL", Format.formatString(serviceBroker.broker_url));
    
    if (row[5] != null)
    {
        this.addFilterRow(table, "Service Broker Events", Format.formatNumber(row[5]), serviceBroker.guid, AdminUI.showEvents);
    }
    
    if (row[6] != null)
    {
        this.addFilterRow(table, "Service Dashboard Client", Format.formatStringCleansed(row[6]), row[6], AdminUI.showClients);
    }
    
    if (row[7] != null)
    {
        this.addFilterRow(table, "Services", Format.formatNumber(row[7]), serviceBroker.guid, AdminUI.showServices);
    }
    
    if (row[8] != null)
    {
        this.addFilterRow(table, "Service Plans", Format.formatNumber(row[8]), serviceBroker.guid, AdminUI.showServicePlans);
    }
    
    if (row[9] != null)
    {
        this.addFilterRow(table, "Service Plan Visibilities", Format.formatNumber(row[9]), serviceBroker.guid, AdminUI.showServicePlanVisibilities);
    }
    
    if (row[10] != null)
    {
        this.addFilterRow(table, "Service Instances", Format.formatNumber(row[10]), serviceBroker.guid, AdminUI.showServiceInstances);
    }
    
    if (row[11] != null)
    {
        this.addFilterRow(table, "Service Bindings", Format.formatNumber(row[11]), serviceBroker.guid, AdminUI.showServiceBindings);
    }
    
    if (row[12] != null)
    {
        this.addFilterRow(table, "Service Keys", Format.formatNumber(row[12]), serviceBroker.guid, AdminUI.showServiceKeys);
    }
};
