
function SharedServiceInstancesTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SHARED_SERVICE_INSTANCES, Constants.URL__SHARED_SERVICE_INSTANCES_VIEW_MODEL);
}

SharedServiceInstancesTab.prototype = new Tab();

SharedServiceInstancesTab.prototype.constructor = SharedServiceInstancesTab;

SharedServiceInstancesTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var label = item[0];
                                          if ((item[1] != null) && (item[26] != null))
                                          {
                                              label = item[1] + "/" + item[26];
                                          }

                                          return this.formatCheckbox(this.id, label, value);
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
                   title:  "Unique ID",
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
                   title:  "Bindable",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Free",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Active",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Public",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Label",
                   width:  "200px",
                   render: Format.formatServiceString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Unique ID",
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
                   title:  "Bindable",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Active",
                   width:  "10px",
                   render: Format.formatBoolean
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
                   title:  "Source",
                   width:  "200px",
                   render: Format.formatTarget
               },
               {
                   title:  "Target",
                   width:  "200px",
                   render: Format.formatTarget
               }
           ];
};

SharedServiceInstancesTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Unshare",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to unshare the selected service instance shares?",
                                                         "Unshare",
                                                         "Unsharing Service Instances",
                                                         Constants.URL__SHARED_SERVICE_INSTANCES,
                                                         "");
                                  },
                                  this)
               }
           ];
};

SharedServiceInstancesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

SharedServiceInstancesTab.prototype.showDetails = function(table, objects, row)
{
    var service              = objects.service;
    var serviceBroker        = objects.service_broker;
    var serviceInstance      = objects.service_instance;
    var serviceInstanceShare = objects.service_instance_share;
    var servicePlan          = objects.service_plan;
    var sourceOrganization   = objects.source_organization;
    var sourceSpace          = objects.source_space;
    var targetOrganization   = objects.target_organization;
    var targetSpace          = objects.target_space;

    var first = true;
    if (serviceInstance != null)
    {
        this.addPropertyRow(table, "Service Instance Name", Format.formatString(serviceInstance.name), true);
        first = false;
    }

    var serviceInstanceLink = this.createFilterLink(Format.formatString(serviceInstanceShare.service_instance_guid), serviceInstanceShare.service_instance_guid, AdminUI.showServiceInstances);
    var details = document.createElement("div");
    $(details).append(serviceInstanceLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "Service Instance GUID", details, first);

    if (serviceInstance != null)
    {
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
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Bindable", Format.formatBoolean, servicePlan.bindable);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Free", Format.formatBoolean, servicePlan.free);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Active", Format.formatBoolean, servicePlan.active);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Public", Format.formatBoolean, servicePlan.public);
    }

    if (service != null)
    {
        this.addFilterRow(table, "Service Label", Format.formatStringCleansed(service.label), service.guid, AdminUI.showServices);
        this.addPropertyRow(table, "Service GUID", Format.formatString(service.guid));
        this.addRowIfValue(this.addPropertyRow, table, "Service Unique ID", Format.formatString, service.unique_id);
        this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
        this.addRowIfValue(this.addPropertyRow, table, "Service Bindable", Format.formatBoolean, service.bindable);
        this.addPropertyRow(table, "Service Active", Format.formatBoolean(service.active));
    }

    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker Name", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    }

    if (sourceSpace != null)
    {
        this.addFilterRow(table, "Source Space", Format.formatStringCleansed(sourceSpace.name), sourceSpace.guid, AdminUI.showSpaces);
        this.addPropertyRow(table, "Source Space GUID", Format.formatString(sourceSpace.guid));
    }

    if (sourceOrganization != null)
    {
        this.addFilterRow(table, "Source Organization", Format.formatStringCleansed(sourceOrganization.name), sourceOrganization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Source Organization GUID", Format.formatString(sourceOrganization.guid));
    }

    if (targetSpace != null)
    {
        this.addFilterRow(table, "Target Space", Format.formatStringCleansed(targetSpace.name), targetSpace.guid, AdminUI.showSpaces);
    }

    this.addPropertyRow(table, "Target Space GUID", Format.formatString(serviceInstanceShare.target_space_guid));

    if (targetOrganization != null)
    {
        this.addFilterRow(table, "Target Organization", Format.formatStringCleansed(targetOrganization.name), targetOrganization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Target Organization GUID", Format.formatString(targetOrganization.guid));
    }
};
