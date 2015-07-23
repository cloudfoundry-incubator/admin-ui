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
                   "sTitle":    Tab.prototype.formatCheckboxHeader(this.id),
                   "sType":     "html",
                   "sWidth":    "2px",
                   "bSortable": false,
                   "mRender":   $.proxy(function(value, type, item)
                   {
                       return this.formatCheckbox(item[1], value);
                   },
                   this),
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
                   "sTitle":  "Public Service Plans",
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
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "200px",
                   "mRender": Format.formatTarget
               }
           ];
};

ServiceBrokersTab.prototype.getActions = function()
{
    return [
               {
                   text: "Rename",
                   click: $.proxy(function()
                   {
                       this.renameSingleChecked("Rename Service Broker",
                                                "Managing Service Brokers",
                                                Constants.URL__SERVICE_BROKERS);
                   }, 
                   this)
               },
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

ServiceBrokersTab.prototype.showDetails = function(table, objects, row)
{
    var organization  = objects.organization;
    var serviceBroker = objects.service_broker;
    var space         = objects.space;
    
    this.addJSONDetailsLinkRow(table, "Service Broker Name", Format.formatString(serviceBroker.name), objects, true);
    this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
    this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Service Broker Auth Username", Format.formatString, serviceBroker.auth_username);
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
    
    this.addRowIfValue(this.addPropertyRow, table, "Public Service Plans", Format.formatNumber, row[9]);
    
    if (row[10] != null)
    {
        this.addFilterRow(table, "Service Plan Visibilities", Format.formatNumber(row[10]), serviceBroker.guid, AdminUI.showServicePlanVisibilities);
    }
    
    if (row[11] != null)
    {
        this.addFilterRow(table, "Service Instances", Format.formatNumber(row[11]), serviceBroker.guid, AdminUI.showServiceInstances);
    }
    
    if (row[12] != null)
    {
        this.addFilterRow(table, "Service Bindings", Format.formatNumber(row[12]), serviceBroker.guid, AdminUI.showServiceBindings);
    }
    
    if (row[13] != null)
    {
        this.addFilterRow(table, "Service Keys", Format.formatNumber(row[13]), serviceBroker.guid, AdminUI.showServiceKeys);
    }
    
    if (space != null)
    {
        this.addFilterRow(table, "Space", Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    }
};
