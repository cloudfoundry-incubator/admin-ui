function ServicesTab(id) 
{
    Tab.call(this, id, Constants.URL__SERVICES_VIEW_MODEL);
}

ServicesTab.prototype = new Tab();

ServicesTab.prototype.constructor = ServicesTab;

ServicesTab.prototype.getInitialSort = function() 
{
    return [[2, "asc"]];
};

ServicesTab.prototype.getColumns = function() 
{
    return [
                {
                   "sTitle":    "&nbsp;",
                   "sWidth":    "2px",
                   "sClass":    "cellCenterAlign",
                   "bSortable": false,
                   "mRender":   function(value, type, item)
                   {
                       var name = "";
                       if (item[1] != null && item[1] != "")
                       {
                           name += item[1] + ".";
                       }
                       name += item[2];
                       
                       return Tab.prototype.formatCheckbox(name, value);
                   }
               },
               {
                    "sTitle": "Provider",
                    "sWidth": "100px",
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
                    "sTitle": "Version",
                    "sWidth": "100px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle": "Created",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Updated",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Active",
                    "sWidth": "70px",
                    "mRender": Format.formatBoolean
                },
                {
                    "sTitle":  "Bindable",
                    "sWidth":  "70px",
                    "mRender": Format.formatBoolean
                },
                {
                    "sTitle":  "Plan Updateable",
                    "sWidth":  "70px",
                    "mRender": Format.formatBoolean
                },
                {
                    "sTitle":  "Events",
                    "sWidth":  "70px",
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
                }
            ];
};

ServicesTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected services?",
                                          "Delete",
                                          "Deleting Services",
                                          Constants.URL__SERVICES,
                                          "");
                   },
                   this)
               },
               {
                   text: "Purge",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to purge the selected services?",
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
    this.itemClicked(-1, 3);
};

ServicesTab.prototype.showDetails = function(table, objects, row)
{
    var service       = objects.service;
    var serviceBroker = objects.service_broker;

    this.addRowIfValue(this.addPropertyRow, table, "Service Provider", Format.formatString, service.provider);
    this.addJSONDetailsLinkRow(table, "Service Label", Format.formatString(service.label), objects, true);
    this.addPropertyRow(table, "Service GUID", Format.formatString(service.guid));
    this.addRowIfValue(this.addPropertyRow, table, "Service Unique ID", Format.formatString, service.unique_id);
    this.addRowIfValue(this.addPropertyRow, table, "Service Version", Format.formatString, service.version);
    this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
    this.addPropertyRow(table, "Service Active", Format.formatBoolean(service.active));
    this.addRowIfValue(this.addPropertyRow, table, "Service Bindable", Format.formatBoolean, service.bindable);
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updateable", Format.formatBoolean, service.plan_updateable);
    this.addPropertyRow(table, "Service Description", Format.formatString(service.description));
    this.addRowIfValue(this.addPropertyRow, table, "Service URL", Format.formatString, service.url);
    
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
    
    // Documentation URL for v1 service
    if (service.documentation_url != null)
    {
        this.addURIRow(table, "Service Documentation URL", service.documentation_url);
    }

    // Info URL for v1 service
    if (service.info_url != null)
    {
        this.addURIRow(table, "Service Info URL", service.info_url);
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
    
    if (row[11] != null)
    {
        this.addFilterRow(table, "Service Events", Format.formatNumber(row[11]), service.guid, AdminUI.showEvents);
    }
    
    if (row[12] != null)
    {
        this.addFilterRow(table, "Service Plans", Format.formatNumber(row[12]), service.guid, AdminUI.showServicePlans);
    }
    
    if (row[13] != null)
    {
        this.addFilterRow(table, "Service Plan Visibilities", Format.formatNumber(row[13]), service.guid, AdminUI.showServicePlanVisibilities);
    }
    
    if (row[14] != null)
    {
        this.addFilterRow(table, "Service Instances", Format.formatNumber(row[14]), service.guid, AdminUI.showServiceInstances);
    }
    
    if (row[15] != null)
    {
        this.addFilterRow(table, "Service Bindings", Format.formatNumber(row[15]), service.guid, AdminUI.showServiceBindings);
    }
    
    if (row[16] != null)
    {
        this.addFilterRow(table, "Service Keys", Format.formatNumber(row[16]), service.guid, AdminUI.showServiceKeys);
    }
    
    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker Name", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    }
};
