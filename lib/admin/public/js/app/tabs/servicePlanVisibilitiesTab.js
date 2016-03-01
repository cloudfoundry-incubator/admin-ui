
function ServicePlanVisibilitiesTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SERVICE_PLAN_VISIBILITIES, Constants.URL__SERVICE_PLAN_VISIBILITIES_VIEW_MODEL);
}

ServicePlanVisibilitiesTab.prototype = new Tab();

ServicePlanVisibilitiesTab.prototype.constructor = ServicePlanVisibilitiesTab;

ServicePlanVisibilitiesTab.prototype.getColumns = function()
{
    return [
               {
                   "title":     Tab.prototype.formatCheckboxHeader(this.id),
                   "type":      "html",
                   "width":     "2px",
                   "orderable": false,
                   "render":    $.proxy(function(value, type, item)
                   {
                       return this.formatCheckbox(item[1], value);
                   },
                   this)
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Created",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Updated",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":     "Events",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatServiceString
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Unique ID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Created",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Updated",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Active",
                   "width":  "70px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Public",
                   "width":  "70px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Free",
                   "width":  "70px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Provider",
                   "width":  "200px",
                   "render": Format.formatServiceString
               },
               {
                   "title":  "Label",
                   "width":  "200px",
                   "render": Format.formatServiceString
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Unique ID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Version",
                   "width":  "200px",
                   "render": Format.formatServiceString
               },
               {
                   "title":  "Created",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Updated",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Active",
                   "width":  "70px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Bindable",
                   "width":  "70px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatServiceString
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Created",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Updated",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Name",
                   "width":  "100px",
                   "render": Format.formatOrganizationName
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Created",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Updated",
                   "width":  "170px",
                   "render": Format.formatString
               }
           ];
};

ServicePlanVisibilitiesTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected service plan visibilities?",
                                          "Delete",
                                          "Deleting Service Plan Visibilities",
                                          Constants.URL__SERVICE_PLAN_VISIBILITIES,
                                          "");
                   },
                   this)
               },
           ];
};

ServicePlanVisibilitiesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

ServicePlanVisibilitiesTab.prototype.showDetails = function(table, objects, row)
{
    var organization          = objects.organization;
    var service               = objects.service;
    var serviceBroker         = objects.service_broker;
    var servicePlan           = objects.service_plan;
    var servicePlanVisibility = objects.service_plan_visibility;

    this.addJSONDetailsLinkRow(table, "Service Plan Visibility GUID", Format.formatString(servicePlanVisibility.guid), objects, true);
    this.addPropertyRow(table, "Service Plan Visibility Created", Format.formatDateString(servicePlanVisibility.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Visibility Updated", Format.formatDateString, servicePlanVisibility.updated_at);
    
    if (row[4] != null)
    {
        this.addFilterRow(table, "Service Plan Visibility Events", Format.formatNumber(row[4]), servicePlanVisibility.guid, AdminUI.showEvents);
    }
    
    if (servicePlan != null)
    {
        this.addFilterRow(table, "Service Plan Name", Format.formatStringCleansed(servicePlan.name), servicePlan.guid, AdminUI.showServicePlans);
        this.addPropertyRow(table, "Service Plan GUID", Format.formatString(servicePlan.guid));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Unique ID", Format.formatString, servicePlan.unique_id);
        this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updated", Format.formatDateString, servicePlan.updated_at);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Active", Format.formatBoolean, servicePlan.active);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Public", Format.formatBoolean, servicePlan.public);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Free", Format.formatBoolean, servicePlan.free);
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
        this.addRowIfValue(this.addPropertyRow, table, "Service Bindable", Format.formatBoolean, service.bindable);
    }
    
    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker Name", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization Name", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
        this.addPropertyRow(table, "Organization Created", Format.formatDateString(organization.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Organization Updated", Format.formatDateString, organization.updated_at);
    }
};
