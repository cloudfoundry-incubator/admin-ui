
function ServiceBrokersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SERVICE_BROKERS, Constants.URL__SERVICE_BROKERS_VIEW_MODEL);
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
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[1], value);
                                      },
                                      this)
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatServiceString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:     "Events",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Service Dashboard Client",
                   width:  "300px",
                   render: Format.formatUserString
               },
               {
                   title:     "Services",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Plans",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Public Active Service Plans",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Plan Visibilities",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Instances",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Instance Shares",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Bindings",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Keys",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Route Bindings",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Target",
                   width:  "200px",
                   render: Format.formatTarget
               }
           ];
};

ServiceBrokersTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Rename",
                   click: $.proxy(function()
                                  {
                                      this.renameSingleChecked(this.id,
                                                               "Rename Service Broker",
                                                               "Managing Service Brokers",
                                                               Constants.URL__SERVICE_BROKERS);
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected service brokers?",
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
    this.addFilterRowIfValue(table, "Service Broker Events", Format.formatNumber, row[5], serviceBroker.guid, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Service Dashboard Client", Format.formatStringCleansed, row[6], row[6], AdminUI.showClients);
    this.addFilterRowIfValue(table, "Services", Format.formatNumber, row[7], serviceBroker.guid, AdminUI.showServices);
    this.addFilterRowIfValue(table, "Service Plans", Format.formatNumber, row[8], serviceBroker.guid, AdminUI.showServicePlans);
    this.addRowIfValue(this.addPropertyRow, table, "Public Active Service Plans", Format.formatNumber, row[9]);
    this.addFilterRowIfValue(table, "Service Plan Visibilities", Format.formatNumber, row[10], serviceBroker.guid, AdminUI.showServicePlanVisibilities);
    this.addFilterRowIfValue(table, "Service Instances", Format.formatNumber, row[11], serviceBroker.guid, AdminUI.showServiceInstances);
    this.addFilterRowIfValue(table, "Service Instance Shares", Format.formatNumber, row[12], serviceBroker.guid, AdminUI.showSharedServiceInstances);
    this.addFilterRowIfValue(table, "Service Bindings", Format.formatNumber, row[13], serviceBroker.guid, AdminUI.showServiceBindings);
    this.addFilterRowIfValue(table, "Service Keys", Format.formatNumber, row[14], serviceBroker.guid, AdminUI.showServiceKeys);
    this.addFilterRowIfValue(table, "Route Bindings", Format.formatNumber, row[15], serviceBroker.guid, AdminUI.showRouteBindings);

    if (space != null)
    {
        this.addFilterRow(table, "Space", Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
        this.addPropertyRow(table, "Space GUID", Format.formatString(space.guid));
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    }
};
