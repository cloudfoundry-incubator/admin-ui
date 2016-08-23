
function ServicePlansTab(id) 
{
    Tab.call(this, id, Constants.FILENAME__SERVICE_PLANS, Constants.URL__SERVICE_PLANS_VIEW_MODEL);
}

ServicePlansTab.prototype             = new Tab();

ServicePlansTab.prototype.constructor = ServicePlansTab;

ServicePlansTab.prototype.getColumns = function() 
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
                   this),
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
                   "width":  "10px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Public",
                   "width":  "10px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Free",
                   "width":  "10px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Display Name",
                   "width":  "200px",
                   "render": Format.formatServiceString
               },
               {
                   "title":     "Events",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Visible Organizations",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Service Instances",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Service Bindings",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Service Keys",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "Provider",
                   "width":  "100px",
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
                   "width":  "100px",
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
                   "width":  "10px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Bindable",
                   "width":  "10px",
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
                       this.updateChecked("Managing Service Plans",
                                          Constants.URL__SERVICE_PLANS,
                                          '{"public":true}');
                   }, 
                   this)
               },
               {
                   text: "Private",
                   click: $.proxy(function() 
                   {
                       this.updateChecked("Managing Service Plans",
                                          Constants.URL__SERVICE_PLANS,
                                          '{"public":false}');
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
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Active", Format.formatBoolean, servicePlan.active);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Public", Format.formatBoolean, servicePlan.public);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Free", Format.formatBoolean, servicePlan.free);
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
        
        if (row[10] != null)
        {
            this.addFilterRow(table, "Service Plan Events", Format.formatNumber(row[10]), servicePlan.guid, AdminUI.showEvents);
        }
        
        if (row[11] != null)
        {
            this.addFilterRow(table, "Service Plan Visibilities", Format.formatNumber(row[11]), servicePlan.guid, AdminUI.showServicePlanVisibilities);
        }
        
        if (row[12] != null)
        {
            this.addFilterRow(table, "Service Instances", Format.formatNumber(row[12]), servicePlan.guid, AdminUI.showServiceInstances);
        }
        
        if (row[13] != null)
        {
            this.addFilterRow(table, "Service Bindings", Format.formatNumber(row[13]), servicePlan.guid, AdminUI.showServiceBindings);
        }
        
        if (row[14] != null)
        {
            this.addFilterRow(table, "Service Keys", Format.formatNumber(row[14]), servicePlan.guid, AdminUI.showServiceKeys);
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
        this.addRowIfValue(this.addPropertyRow, table, "Service Bindable", Format.formatBoolean, service.bindable);
    }
    
    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker Name", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    }
};
