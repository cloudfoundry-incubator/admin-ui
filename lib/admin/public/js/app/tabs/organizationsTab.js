
function OrganizationsTab(id)
{
    Tab.call(this, id, Constants.URL__ORGANIZATIONS_VIEW_MODEL);
}

OrganizationsTab.prototype = new Tab();

OrganizationsTab.prototype.constructor = OrganizationsTab;

OrganizationsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

OrganizationsTab.prototype.getColumns = function()
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
                   "sWidth": "100px",
                   "mRender": Format.formatOrganizationName
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Status",
                   "sWidth":  "80px",
                   "mRender": Format.formatOrganizationStatus
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Events Target",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Spaces",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Organization Roles",
                   "sWidth":  "90px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Space Roles",
                   "sWidth":  "90px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Quota",
                   "sWidth":  "90px",
                   "mRender": Format.formatQuotaName
               },
               {
                   "sTitle":  "Space Quotas",
                   "sWidth":  "90px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Domains",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Service Plan Visibilities",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Total",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Used",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Unused",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Instances",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Services",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Memory",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Disk",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "% CPU",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Memory",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Disk",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Total",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Stopped",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Pending",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Staged",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Failed",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
};

OrganizationsTab.prototype.getActions = function()
{
    return [
               {
                   text: "Create",
                   click: $.proxy(function()
                   {
                       this.createOrg();
                   },
                   this)
               },
               {
                   text: "Set Quota",
                   click: $.proxy(function()
                   {
                       this.manageQuotas();
                   }, 
                   this)
               },
               {
                   text: "Activate",
                   click: $.proxy(function()
                   {
                       this.manageOrganizations("activate");
                   },
                   this)
               },
               {
                   text: "Suspend",
                   click: $.proxy(function()
                   {
                       this.manageOrganizations("suspend");
                   },
                   this)
               },
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected organizations?",
                                          "Delete",
                                          "Deleting Organizations",
                                          Constants.URL__ORGANIZATIONS,
                                          "");
                   },
                   this)
               },
               {
                   text: "Delete Recursive",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected organizations and their contained spaces, space quotas, applications, routes, service instances, service bindings and service keys?",
                                          "Delete Recursive",
                                          "Deleting Organizations and their Contents",
                                          Constants.URL__ORGANIZATIONS,
                                          "?recursive=true");
                   },
                   this)
               }
           ];
};

OrganizationsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

OrganizationsTab.prototype.showDetails = function(table, objects, row)
{
    var organization    = objects.organization;
    var quotaDefinition = objects.quota_definition;
    
    var target = organization.name + "/";

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(organization.name), objects, true);

    this.addPropertyRow(table, "GUID", Format.formatString(organization.guid));
    this.addPropertyRow(table, "Status", Format.formatString(organization.status).toUpperCase());
    this.addPropertyRow(table, "Created", Format.formatDateString(organization.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, organization.updated_at);
    this.addPropertyRow(table, "Billing Enabled", Format.formatBoolean(organization.billing_enabled));
    
    if (row[6] != null)
    {
        this.addFilterRow(table, "Events Target", Format.formatNumber(row[6]), target, AdminUI.showEvents);
    }
    
    if (row[7] != null)
    {
        this.addFilterRow(table, "Spaces", Format.formatNumber(row[7]), target, AdminUI.showSpaces);
    }

    if (row[8] != null)
    {
        this.addFilterRow(table, "Organization Roles", Format.formatNumber(row[8]), organization.guid, AdminUI.showOrganizationRoles);
    }

    if (row[9] != null)
    {
        this.addFilterRow(table, "Space Roles", Format.formatNumber(row[9]), target, AdminUI.showSpaceRoles);
    }
    
    if (quotaDefinition != null)
    {
        this.addFilterRow(table, "Quota", Format.formatStringCleansed(quotaDefinition.name), quotaDefinition.guid, AdminUI.showQuotas);
    }

    if (row[11] != null)
    {
        this.addFilterRow(table, "Space Quotas", Format.formatNumber(row[11]), organization.guid, AdminUI.showSpaceQuotas);
    }
    
    if (row[12] != null)
    {
        this.addFilterRow(table, "Domains", Format.formatNumber(row[12]), organization.name, AdminUI.showDomains);
    }
    
    if (row[13] != null)
    {
        this.addFilterRow(table, "Service Plan Visibilities", Format.formatNumber(row[13]), organization.guid, AdminUI.showServicePlanVisibilities);
    }
    
    if (row[14] != null)
    {
        this.addFilterRow(table, "Total Routes", Format.formatNumber(row[14]), target, AdminUI.showRoutes);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Used Routes", Format.formatNumber, row[15]);
    this.addRowIfValue(this.addPropertyRow, table, "Unused Routes", Format.formatNumber, row[16]);

    if (row[17] != null)
    {
        this.addFilterRow(table, "Instances Used", Format.formatNumber(row[17]), target, AdminUI.showApplicationInstances);
    }

    if (row[18] != null)
    {
        this.addFilterRow(table, "Services Used", Format.formatNumber(row[18]), target, AdminUI.showServiceInstances);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Memory Used", Format.formatNumber, row[19]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used", Format.formatNumber, row[20]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",  Format.formatNumber, row[21]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[22]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[23]);

    if (row[24] != null)
    {
        this.addFilterRow(table, "Total Apps", Format.formatNumber(row[24]), target, AdminUI.showApplications);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Started Apps", Format.formatNumber, row[25]);
    this.addRowIfValue(this.addPropertyRow, table, "Stopped Apps", Format.formatNumber, row[26]);
    this.addRowIfValue(this.addPropertyRow, table, "Pending Apps", Format.formatNumber, row[27]);
    this.addRowIfValue(this.addPropertyRow, table, "Staged Apps",  Format.formatNumber, row[28]);
    this.addRowIfValue(this.addPropertyRow, table, "Failed Apps",  Format.formatNumber, row[29]);
};

OrganizationsTab.prototype.manageOrganizations = function(type)
{
    var orgs = this.getChecked();

    if (!orgs || orgs.length == 0)
    {
        return;
    }

    var buttonText     = "";
    var confirmation   = "";
    var controlMessage = "";

    if (type == "activate")
    {
        buttonText     = "Activate";
        confirmation   = "Are you sure you want to activate the selected organizations?";
        controlMessage = '{"status":"active"}';
    }
    else if (type == "suspend")
    {
        buttonText     = "Suspend";
        confirmation   = "Are you sure you want to suspend the selected organizations?";
        controlMessage = '{"status":"suspended"}';
    }
    else
    {
        return;
    }

    AdminUI.showModalDialogConfirmation(confirmation,
                                        buttonText,
                                        $.proxy(function()
                                        {
                                            this.updateOrganizations(orgs, 
                                                                     controlMessage);
                                        }, this));
};

OrganizationsTab.prototype.manageQuotas = function()
{
    var orgs = this.getChecked();

    if (!orgs || orgs.length == 0)
    {
        return;
    }
    
    var deferred = $.ajax({ 
                              type:     "GET",
                              url:      Constants.URL__QUOTAS_VIEW_MODEL,
                              dataType: "json"
                          });

    deferred.done($.proxy(function(result, status)
    {            
        if (result.items.connected)
        {
            var quotas = result.items.items;
            var dialogContentDiv = $("<div></div>");
            dialogContentDiv.append($("<label>Select a quota: </label>"));

            var selector = $("<select id='quotaSelector'></select>");

            for (var quotaIndex = 0; quotaIndex < quotas.length; quotaIndex++)
            {
                var quotaName = quotas[quotaIndex][1];
                var quotaGUID = quotas[quotaIndex][2];
                selector.append($("<option value='" + quotaGUID + "'>" + quotaName + "</option>"));
            }

            dialogContentDiv.append(selector);

            AdminUI.showModalDialogAction("Set Organization Quota",
                                          dialogContentDiv,
                                          "Set",
                                          $.proxy(function()
                                          {
                                              var controlMessage = '{"quota_definition_guid":"' + $("#quotaSelector").val() + '"}';
                                              
                                              this.updateOrganizations(orgs, 
                                                                       controlMessage);
                                          }, this));
        }
        else
        {
            var error = "Error retrieving quota definitions";
            
            if (result.items.error)
            {
                error += ":<br/><br/>" + result.items.error;
            }    

            AdminUI.showModalDialogError(error);
        }
    }, this));
    
    deferred.fail(function(xhr, status, error)
    {
        if (xhr.status == 303)
        {
            window.location.href = Constants.URL__LOGIN;
        }
        else
        {
            AdminUI.showModalDialogError("Error retrieving quota definitions:<br/><br/>" + error);
        }
    });
};

OrganizationsTab.prototype.updateOrganizations = function(orgs, controlMessage)
{
    AdminUI.showModalDialogProgress("Managing Organizations");

    var processed = 0;
    
    var errorOrgs = [];

    for (var orgIndex = 0; orgIndex < orgs.length; orgIndex++)
    {
        var org = orgs[orgIndex];

        var deferred = $.ajax({
                                  type:             "PUT",
                                  url:              Constants.URL__ORGANIZATIONS + "/" + org.key,
                                  contentType:      "application/json; charset=utf-8",
                                  dataType:         "json",
                                  data:             controlMessage,
                                  // Need organization name inside the fail method
                                  organizationName: org.name
                              });
        
        deferred.fail(function(xhr, status, error)
        {
            errorOrgs.push({
                               label: this.organizationName,
                               xhr:   xhr
                           });
        });
        
        deferred.always(function(xhr, status, error)
        {
            processed++;
             
            if (processed == orgs.length)
            {
                if (errorOrgs.length > 0)
                {
                    AdminUI.showModalDialogErrorTable(errorOrgs);
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

OrganizationsTab.prototype.createOrg = function()
{
    var dialogContentDiv = $("<div></div>");
    dialogContentDiv.append($("<label>Name: </label>"));
    dialogContentDiv.append($("<input type='text' id='organizationName'>"))

    AdminUI.showModalDialogAction("Create Organization",
                                  dialogContentDiv,
                                  "Create",
                                  $.proxy(function()
                                  {
                                      var name = $("#organizationName").val();
                                      if (!name)
                                      {
                                          alert("Please input the name of the organization first!");
                                          return;
                                      }
                                        
                                      this.doCreateOrg(name);
                                  }, this));
};

OrganizationsTab.prototype.doCreateOrg = function(organizationName)
{
    AdminUI.showModalDialogProgress("Managing Organizations");

    var deferred = $.ajax({
                              type:        "POST",
                              url:         Constants.URL__ORGANIZATIONS,
                              contentType: "application/json; charset=utf-8",
                              dataType:    "json",
                              data:        '{"name":"' + organizationName + '"}'
                          });

    deferred.done(function(response, status)
    {
        AdminUI.showModalDialogSuccess();
    });
    
    deferred.fail(function(xhr, status, error)
    {
        AdminUI.showModalDialogErrorTable([
                                              {
                                                  label: organizationName,
                                                  xhr:   xhr
                                              }
                                          ]);
    });
    
    deferred.always(function(xhr, status, error)
    {
        AdminUI.refresh(); 
    });
};
