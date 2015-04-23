
function ServiceKeysTab(id)
{
    Tab.call(this, id, Constants.URL__SERVICE_KEYS_VIEW_MODEL);
}

ServiceKeysTab.prototype = new Tab();

ServiceKeysTab.prototype.constructor = ServiceKeysTab;

ServiceKeysTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

ServiceKeysTab.prototype.getColumns = function()
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
                   "sTitle": "Name",
                   "sWidth": "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Events",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle": "Unique ID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Active",
                   "sWidth":  "70px",
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Public",
                   "sWidth":  "70px",
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Free",
                   "sWidth":  "70px",
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Provider",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Label",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle": "Unique ID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Version",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle": "Active",
                   "sWidth": "70px",
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "200px",
                   "mRender": Format.formatTarget
               }
           ];
};

ServiceKeysTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected service keys?",
                                          "Delete",
                                          "Deleting Service Keys",
                                          Constants.URL__SERVICE_KEYS,
                                          "");
                   },
                   this)
               },
           ];
};

ServiceKeysTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServiceKeysTab.prototype.showDetails = function(table, objects, row)
{
    var organization    = objects.organization;
    var service         = objects.service;
    var serviceBroker   = objects.service_broker;
    var serviceInstance = objects.service_instance;
    var serviceKey      = objects.service_key;
    var servicePlan     = objects.service_plan;
    var space           = objects.space;

    this.addJSONDetailsLinkRow(table, "Service Key Name", Format.formatString(serviceKey.name), objects, true);
    this.addPropertyRow(table, "Service Key GUID", Format.formatString(serviceKey.guid));
    this.addPropertyRow(table, "Service Key Created", Format.formatDateString(serviceKey.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Key Updated", Format.formatDateString, serviceKey.updated_at);
    
    if (row[5] != null)
    {
        this.addFilterRow(table, "Service Key Events", Format.formatNumber(row[5]), serviceKey.guid, AdminUI.showEvents);
    }
    
    if (serviceInstance != null)
    {
        this.addFilterRow(table, "Service Instance Name", Format.formatStringCleansed(serviceInstance.name), serviceInstance.guid, AdminUI.showServiceInstances);
        this.addPropertyRow(table, "Service Instance GUID", Format.formatString(serviceInstance.guid));
        this.addPropertyRow(table, "Service Instance Created", Format.formatDateString(serviceInstance.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Instance Updated", Format.formatDateString, serviceInstance.updated_at);
    }
    
    if (servicePlan != null)
    {
        this.addFilterRow(table, "Service Plan Name", Format.formatStringCleansed(servicePlan.name), servicePlan.guid, AdminUI.showServicePlans);
        this.addPropertyRow(table, "Service Plan GUID", Format.formatString(servicePlan.guid));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Unique ID", Format.formatString, servicePlan.unique_id);
        this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updated", Format.formatDateString, servicePlan.updated_at);
        this.addPropertyRow(table, "Service Plan Active", Format.formatBoolean(servicePlan.active));
        this.addPropertyRow(table, "Service Plan Public", Format.formatBoolean(servicePlan.public));
        this.addPropertyRow(table, "Service Plan Free", Format.formatBoolean(servicePlan.free));
    }

    if (service != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Service Provider", Format.formatString, service.provider);
        this.addFilterRow(table, "Service Label", Format.formatStringCleansed(service.label), service.guid, AdminUI.showServices);
        this.addPropertyRow(table, "Service GUID", Format.formatString(service.guid));
        this.addRowIfValue(this.addPropertyRow, table, "Service Unique ID", Format.formatString, service.unique_id);
        this.addRowIfValue(this.addPropertyRow, table, "Service Version", Format.formatString, service.version);
        this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
        this.addPropertyRow(table, "Service Active", Format.formatBoolean(service.active));
    }
    
    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker Name", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
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
