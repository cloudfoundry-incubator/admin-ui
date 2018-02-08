
function ServicesTab(id) 
{
    Tab.call(this, id, Constants.FILENAME__SERVICES, Constants.URL__SERVICES_VIEW_MODEL);
}

ServicesTab.prototype = new Tab();

ServicesTab.prototype.constructor = ServicesTab;

ServicesTab.prototype.getInitialSort = function() 
{
    return [[1, "asc"]];
};

ServicesTab.prototype.getColumns = function() 
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
                   title:  "Plan Updateable",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Shareable",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Active",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Provider Display Name",
                   width:  "100px",
                   render: Format.formatServiceString
               },
               {
                   title:  "Display Name",
                   width:  "200px",
                   render: Format.formatServiceString
               },
               {
                   title:  "Requires",
                   width:  "200px",
                   render: Format.formatServiceStrings
               },
               {
                   title:     "Events",
                   width:     "70px",
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
               }
           ];
};

ServicesTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected services?",
                                                         "Delete",
                                                         "Deleting Services",
                                                         Constants.URL__SERVICES,
                                                         "");
                                  },
                                  this)
               },
               {
                   text:  "Purge",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to purge the selected services?",
                                                         "Purge",
                                                         "Purging Services",
                                                         Constants.URL__SERVICES,
                                                         "?purge=true");
                                  },
                                  this)
               }
           ];
};

ServicesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServicesTab.prototype.showDetails = function(table, objects, row)
{
    var service       = objects.service;
    var serviceBroker = objects.service_broker;

    this.addJSONDetailsLinkRow(table, "Service Label", Format.formatString(service.label), objects, true);
    this.addPropertyRow(table, "Service GUID", Format.formatString(service.guid));
    this.addRowIfValue(this.addPropertyRow, table, "Service Unique ID", Format.formatString, service.unique_id);
    this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Service Bindable", Format.formatBoolean, service.bindable);
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updateable", Format.formatBoolean, service.plan_updateable);
    this.addRowIfValue(this.addPropertyRow, table, "Service Shareable", Format.formatBoolean, row[8]);
    this.addPropertyRow(table, "Service Active", Format.formatBoolean(service.active));
    this.addPropertyRow(table, "Service Description", Format.formatString(service.description));

    if (row[12] != null)
    {
        for (var index = 0; index < row[12].length; index++)
        {
            var field = row[12][index];
            this.addPropertyRow(table, "Service Requires", Format.formatString(field));
        }
    }

    if (service.tags != null)
    {
        try
        {
            var serviceTags = jQuery.parseJSON(service.tags);
            
            if (serviceTags != null && serviceTags.length > 0)
            {
                for (var serviceTagIndex = 0; serviceTagIndex < serviceTags.length; serviceTagIndex++)
                {
                    var serviceTag = serviceTags[serviceTagIndex];
    
                    this.addPropertyRow(table, "Service Tag", Format.formatString(serviceTag));
                }
            }
        }
        catch (error)
        {
        }
    }
    
    if (service.extra != null)
    {
        try
        {
            var serviceExtra = jQuery.parseJSON(service.extra);
            
            this.addRowIfValue(this.addPropertyRow, table, "Service Display Name", Format.formatString, serviceExtra.displayName);
            this.addRowIfValue(this.addPropertyRow, table, "Service Provider Display Name", Format.formatString, serviceExtra.providerDisplayName);
            this.addRowIfValue(this.addFormattableTextRow, table, "Service Icon", Format.formatIconImage, serviceExtra.imageUrl, "service icon", "flot:left;");
            this.addRowIfValue(this.addPropertyRow, table, "Service Long Description", Format.formatString, serviceExtra.longDescription);
            
            if (serviceExtra.documentationUrl != null)
            {
                this.addURIRow(table, "Service Documentation URL", serviceExtra.documentationUrl);
            }
            
            if (serviceExtra.supportUrl != null)
            {
                this.addURIRow(table, "Service Support URL", serviceExtra.supportUrl);
            }
        }
        catch (error)
        {
        }
    }
    
    this.addFilterRowIfValue(table, "Service Events", Format.formatNumber, row[13], service.guid, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Service Plans", Format.formatNumber, row[14], service.guid, AdminUI.showServicePlans);
    this.addRowIfValue(this.addPropertyRow, table, "Public Active Service Plans", Format.formatNumber, row[15]);
    this.addFilterRowIfValue(table, "Service Plan Visibilities", Format.formatNumber, row[16], service.guid, AdminUI.showServicePlanVisibilities);
    this.addFilterRowIfValue(table, "Service Instances", Format.formatNumber, row[17], service.guid, AdminUI.showServiceInstances);
    this.addFilterRowIfValue(table, "Service Instance Shares", Format.formatNumber, row[18], service.guid, AdminUI.showSharedServiceInstances);
    this.addFilterRowIfValue(table, "Service Bindings", Format.formatNumber, row[19], service.guid, AdminUI.showServiceBindings);
    this.addFilterRowIfValue(table, "Service Keys", Format.formatNumber, row[20], service.guid, AdminUI.showServiceKeys);
    this.addFilterRowIfValue(table, "Route Bindings", Format.formatNumber, row[21], service.guid, AdminUI.showRouteBindings);
    
    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker Name", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    }
};
