function ServicePlansTab(id) 
{
    Tab.call(this, id, Constants.URL__SERVICE_PLANS_VIEW_MODEL);
}

ServicePlansTab.prototype             = new Tab();

ServicePlansTab.prototype.constructor = ServicePlansTab;

ServicePlansTab.prototype.getInitialSort = function() 
{
    return [[1, "asc"]];
};

ServicePlansTab.prototype.getColumns = function() 
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
                    "sTitle": "Unique ID",
                    "sWidth": "200px",
                    "mRender": Format.formatString
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
                    "sTitle":  "Events",
                    "sWidth":  "70px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.formatNumber
                },
                {
                    "sTitle":  "Visible Organizations",
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

ServicePlansTab.prototype.getActions = function() 
{
    return [
               {
                   text: " Public ",
                   click: $.proxy(function() 
                   {
                       this.changeVisibility("public");
                   }, 
                   this)
               },
               {
                   text: "Private",
                   click: $.proxy(function() 
                   {
                       this.changeVisibility("private");
                   }, 
                   this)
               },
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected service plans?",
                                          "Delete",
                                          "Deleting Service Plans",
                                          Constants.URL__SERVICE_PLANS,
                                          "");
                   },
                   this)
               }
           ];
};

ServicePlansTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServicePlansTab.prototype.showDetails = function(table, objects, row)
{
    var service       = objects.service;
    var serviceBroker = objects.service_broker;
    var servicePlan   = objects.service_plan;

    if (servicePlan != null)
    {
        this.addJSONDetailsLinkRow(table, "Service Plan Name", Format.formatString(servicePlan.name), objects, true);
        this.addPropertyRow(table, "Service Plan GUID", Format.formatString(servicePlan.guid));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Unique ID", Format.formatString, servicePlan.unique_id);
        this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updated", Format.formatDateString, servicePlan.updated_at);
        this.addPropertyRow(table, "Service Plan Active", Format.formatBoolean(servicePlan.active));
        this.addPropertyRow(table, "Service Plan Public", Format.formatBoolean(servicePlan.public));
        this.addPropertyRow(table, "Service Plan Free", Format.formatBoolean(servicePlan.free));
        this.addPropertyRow(table, "Service Plan Description", Format.formatString(servicePlan.description));
        
        if (servicePlan.extra != null)
        {
            try
            {
                var servicePlanExtra = jQuery.parseJSON(servicePlan.extra);
                
                this.addRowIfValue(this.addPropertyRow, table, "Service Plan Display Name", Format.formatString, servicePlanExtra.displayName);
                
                if (servicePlanExtra.bullets != null)
                {
                    var bullets = servicePlanExtra.bullets;
                    
                    for (var bulletIndex = 0; bulletIndex < bullets.length; bulletIndex++)
                    {
                        this.addPropertyRow(table, "Service Plan Bullet", Format.formatString(bullets[bulletIndex]));
                    }
                }
            }
            catch (error)
            {
            }
        }
        
        if (row[9] != null)
        {
            this.addFilterRow(table, "Service Plan Events", Format.formatNumber(row[9]), servicePlan.guid, AdminUI.showEvents);
        }
        
        if (row[10] != null)
        {
            this.addFilterRow(table, "Service Plan Visibilities", Format.formatNumber(row[10]), servicePlan.guid, AdminUI.showServicePlanVisibilities);
        }
        
        if (row[11] != null)
        {
            this.addFilterRow(table, "Service Instances", Format.formatNumber(row[11]), servicePlan.guid, AdminUI.showServiceInstances);
        }
        
        if (row[12] != null)
        {
            this.addFilterRow(table, "Service Bindings", Format.formatNumber(row[12]), servicePlan.guid, AdminUI.showServiceBindings);
        }
        
        if (row[13] != null)
        {
            this.addFilterRow(table, "Service Keys", Format.formatNumber(row[13]), servicePlan.guid, AdminUI.showServiceKeys);
        }
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
        this.addPropertyRow(table, "Service Bindable", Format.formatBoolean(service.bindable));
    }
    
    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker Name", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    }
};

ServicePlansTab.prototype.changeVisibility = function(targetedVisibility) 
{
    if (!targetedVisibility || 
        (targetedVisibility != Constants.STATUS__PUBLIC && 
         targetedVisibility != Constants.STATUS__PRIVATE ) ) 
    {
        return;
    }

    var servicePlans = this.getChecked();

    if (!servicePlans || servicePlans.length == 0) 
    {
        return;
    }

    var body = (targetedVisibility === Constants.STATUS__PUBLIC) ? '{"public": true}': '{"public": false }';
    
    var processed = 0;
    
    var errorServicePlans = [];
    
    AdminUI.showModalDialogProgress("Managing Service Plans");

    for (var servicePlanIndex = 0; servicePlanIndex < servicePlans.length; servicePlanIndex++) 
    {
        var servicePlan = servicePlans[servicePlanIndex];
        
        var deferred = $.ajax({
                                  type:              "PUT",
                                  url:               Constants.URL__SERVICE_PLANS + "/" + servicePlan.key,
                                  contentType:       "application/json; charset=utf-8",
                                  data:              body,
                                  // Need service plan target inside the fail method
                                  servicePlanTarget: servicePlan.name
                              });
        
        deferred.fail(function(xhr, status, error) 
        {
            errorServicePlans.push({
                                       label: this.servicePlanTarget,
                                       xhr:   xhr
                                   });
        });
        
        deferred.always(function(xhr, status, error)
        {
            processed++;
            
            if (processed == servicePlans.length)
            {
                if (errorServicePlans.length > 0) 
                {
                    AdminUI.showModalDialogErrorTable(errorServicePlans);
                } 
                else
                {
                    AdminUI.showModalDialogSuccess();
                }

                AdminUI.refresh();
            }
        });
    }
};
