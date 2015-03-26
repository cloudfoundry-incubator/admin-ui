function ServicePlansTab(id) 
{
    Tab.call(this, id, Constants.URL__SERVICE_PLANS_VIEW_MODEL);
}

ServicePlansTab.prototype             = new Tab();

ServicePlansTab.prototype.constructor = ServicePlansTab;

ServicePlansTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.servicePlansOrganizationsTable = Table.createTable("ServicePlansOrganizations", this.getOrganizationsColumns(), [[0, "asc"]], null, null, null, null);
};

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
                        return "<input type='checkbox' name='" + escape(item[3]) + "' value='" + value + "' onclick='ServicePlansTab.prototype.checkboxClickHandler(event)'></input>";
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
                    "sTitle":  "Visible Organizations",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },
                {
                    "sTitle":  "Service Instances",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },
                {
                    "sTitle":  "Service Bindings",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
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

ServicePlansTab.prototype.getOrganizationsColumns = function()
{
    return [
               {
                   "sTitle":  "Organization",
                   "sWidth":  "100px",
                   "mRender": function(name, type, row)
                   {
                       var organizationName = Format.formatOrganizationName(name, type);
                       
                       if (Format.doFormatting(type))
                       {
                           return "<a class='tableLink' onclick='AdminUI.showOrganizations(\"" + 
                                  row[1] + 
                                  "\")'>" + 
                                  organizationName +
                                  "</a><img onclick='ServicePlansTab.prototype.displayOrganizationDetail(event, \"" + 
                                  row[3] + 
                                  "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
                       }

                       return organizationName;
                   }
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatDateString
               },
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
               }
           ];
};

ServicePlansTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);
    
    $("#ServicePlansOrganizationsTableContainer").hide();
};

ServicePlansTab.prototype.linkClickHandler = function(service_plan_name) 
{
    AdminUI.showServiceInstances(service_plan_name);
};

ServicePlansTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServicePlansTab.prototype.showDetails = function(table, objects, row)
{
    var service                                 = objects.service;
    var serviceBroker                           = objects.service_broker;
    var servicePlan                             = objects.service_plan;
    var servicePlanVisibilitiesAndOrganizations = objects.service_plan_visibilities_and_organizations;

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
        
        if (row[10] != null)
        {
            this.addFilterRow(table, "Service Instances", Format.formatNumber(row[10]), servicePlan.guid, AdminUI.showServiceInstances);
        }
        
        if (row[11] != null)
        {
            this.addFilterRow(table, "Service Bindings", Format.formatNumber(row[11]), servicePlan.guid, AdminUI.showServiceBindings);
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
    
    if (servicePlanVisibilitiesAndOrganizations != null && servicePlanVisibilitiesAndOrganizations.length > 0)
    {
        // Have to show the table prior to populating for its sizing to work correctly.
        $("#ServicePlansOrganizationsTableContainer").show();

        var servicePlansOrganizationsTableData = [];

        for (var servicePlanVisibilityAndOrganizationIndex = 0; servicePlanVisibilityAndOrganizationIndex < servicePlanVisibilitiesAndOrganizations.length; servicePlanVisibilityAndOrganizationIndex++)
        {
            var servicePlanVisibilityAndOrganization = servicePlanVisibilitiesAndOrganizations[servicePlanVisibilityAndOrganizationIndex];
            var organization                         = servicePlanVisibilityAndOrganization.organization;
            var servicePlanVisibility                = servicePlanVisibilityAndOrganization.service_plan_visibility;

            var organizationRow = [];

            organizationRow.push(organization.name);
            organizationRow.push(organization.guid);
            organizationRow.push(servicePlanVisibility.created_at);

            // Need both the index and the actual object in the table
            organizationRow.push(servicePlanVisibilityAndOrganizationIndex);
            organizationRow.push(servicePlanVisibilityAndOrganization);

            servicePlansOrganizationsTableData.push(organizationRow);
        }

        this.servicePlansOrganizationsTable.fnClearTable();
        this.servicePlansOrganizationsTable.fnAddData(servicePlansOrganizationsTableData);
    }
};

ServicePlansTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

ServicePlansTab.prototype.changeVisibility = function(targetedVisibility) 
{
    if (!targetedVisibility || 
        (targetedVisibility != Constants.STATUS__PUBLIC && 
         targetedVisibility != Constants.STATUS__PRIVATE ) ) 
    {
        return;
    }

    var servicePlans = this.getSelectedServicePlans();

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
                                  url:               Constants.URL__SERVICE_PLANS + "/" + servicePlan.guid,
                                  contentType:       "application/json; charset=utf-8",
                                  data:              body,
                                  // Need service plan target inside the fail method
                                  servicePlanTarget: servicePlan.target
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

ServicePlansTab.prototype.getSelectedServicePlans = function() 
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        AdminUI.showModalDialogError("Please select at least one row!");
        
        return null;
    }

    var servicePlans = [];

    for (var checkedIndex = 0; checkedIndex < checkedRows.length; checkedIndex++)
    {
        var checkedRow = checkedRows[checkedIndex];
        
        servicePlans.push({
                              target: unescape(checkedRow.name),
                              guid:   checkedRow.value
                          });
    }

    return servicePlans;
};

ServicePlansTab.prototype.displayOrganizationDetail = function(event, rowIndex)
{
    var row = $("#ServicePlansOrganizationsTable").dataTable().fnGetData(rowIndex);

    var organization = row[4];

    Utilities.windowOpen(organization);

    event.stopPropagation();

    return false;
};
