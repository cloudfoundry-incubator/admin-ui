
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
                   "mRender":   function(value, type)
                   {
                       return "<input type='checkbox' value='" + value + "' onclick='OrganizationsTab.prototype.checkboxClickHandler(event)'></input>";
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
                   "sTitle":  "Domains",
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
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteOrganizations();
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
               }
           ];
};

OrganizationsTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

OrganizationsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

OrganizationsTab.prototype.showDetails = function(table, organization, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(organization.name), organization, true);

    this.addPropertyRow(table, "GUID", Format.formatString(organization.guid));
    this.addPropertyRow(table, "Status", Format.formatString(organization.status).toUpperCase());
    this.addPropertyRow(table, "Created", Format.formatDateString(organization.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, organization.updated_at);
    this.addPropertyRow(table, "Billing Enabled", Format.formatString(organization.billing_enabled));

    if (row[6] != null)
    {
        var spacesLink = document.createElement("a");
        $(spacesLink).attr("href", "");
        $(spacesLink).addClass("tableLink");
        $(spacesLink).html(Format.formatNumber(row[6]));
        $(spacesLink).click(function()
        {
            AdminUI.showSpaces(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Spaces", spacesLink);
    }

    if (row[7] != null)
    {
        var organizationRolesLink = document.createElement("a");
        $(organizationRolesLink).attr("href", "");
        $(organizationRolesLink).addClass("tableLink");
        $(organizationRolesLink).html(Format.formatNumber(row[7]));
        $(organizationRolesLink).click(function()
        {
            AdminUI.showOrganizationRoles(Format.formatString(organization.name));
    
            return false;
        });
        this.addRow(table, "Organization Roles", organizationRolesLink);
    }

    if (row[8] != null)
    {
        var spaceRolesLink = document.createElement("a");
        $(spaceRolesLink).attr("href", "");
        $(spaceRolesLink).addClass("tableLink");
        $(spaceRolesLink).html(Format.formatNumber(row[8]));
        $(spaceRolesLink).click(function()
        {
            AdminUI.showSpaceRoles(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Space Roles", spaceRolesLink);
    }
    
    if (row[9] != null)
    {
        var quotaLink = document.createElement("a");
        $(quotaLink).attr("href", "");
        $(quotaLink).addClass("tableLink");
        $(quotaLink).html(Format.formatString(row[9]));
        $(quotaLink).click(function()
        {
            AdminUI.showQuotas(row[9]);
    
            return false;
        });
        this.addRow(table, "Quota", quotaLink);
    }

    if (row[10] != null)
    {
        var domainsLink = document.createElement("a");
        $(domainsLink).attr("href", "");
        $(domainsLink).addClass("tableLink");
        $(domainsLink).html(Format.formatNumber(row[10]));
        $(domainsLink).click(function()
        {
            AdminUI.showDomains(Format.formatString(organization.name));
    
            return false;
        });
        this.addRow(table, "Domains", domainsLink);
    }
    
    if (row[11] != null)
    {
        var routesLink = document.createElement("a");
        $(routesLink).attr("href", "");
        $(routesLink).addClass("tableLink");
        $(routesLink).html(Format.formatNumber(row[11]));
        $(routesLink).click(function()
        {
            AdminUI.showRoutes(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Total Routes", routesLink);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Used Routes", Format.formatNumber, row[12]);
    this.addRowIfValue(this.addPropertyRow, table, "Unused Routes", Format.formatNumber, row[13]);

    if (row[14] != null)
    {
        var instancesLink = document.createElement("a");
        $(instancesLink).attr("href", "");
        $(instancesLink).addClass("tableLink");
        $(instancesLink).html(Format.formatNumber(row[14]));
        $(instancesLink).click(function()
        {
            AdminUI.showApplications(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Instances Used", instancesLink);
    }

    if (row[15] != null)
    {
        var servicesLink = document.createElement("a");
        $(servicesLink).attr("href", "");
        $(servicesLink).addClass("tableLink");
        $(servicesLink).html(Format.formatNumber(row[15]));
        $(servicesLink).click(function()
        {
            AdminUI.showServiceInstances(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Services Used", servicesLink);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Memory Used", Format.formatNumber, row[16]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used", Format.formatNumber, row[17]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",  Format.formatNumber, row[18]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[19]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[20]);

    if (row[21] != null)
    {
        var appsLink = document.createElement("a");
        $(appsLink).attr("href", "");
        $(appsLink).addClass("tableLink");
        $(appsLink).html(Format.formatNumber(row[21]));
        $(appsLink).click(function()
        {
            AdminUI.showApplications(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Total Apps", appsLink);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Started Apps", Format.formatNumber, row[22]);
    this.addRowIfValue(this.addPropertyRow, table, "Stopped Apps", Format.formatNumber, row[23]);
    this.addRowIfValue(this.addPropertyRow, table, "Pending Apps", Format.formatNumber, row[24]);
    this.addRowIfValue(this.addPropertyRow, table, "Staged Apps",  Format.formatNumber, row[25]);
    this.addRowIfValue(this.addPropertyRow, table, "Failed Apps",  Format.formatNumber, row[26]);
};

OrganizationsTab.prototype.manageOrganizations = function(type)
{
    var orgs = this.getSelectedOrgs();

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
}

OrganizationsTab.prototype.manageQuotas = function()
{
    var orgs = this.getSelectedOrgs();

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
                var quotaName = quotas[quotaIndex][0];
                var quotaGUID = quotas[quotaIndex][1];
                selector.append($("<option value='" + quotaGUID + "'>" + quotaName + "</quota>"));
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

OrganizationsTab.prototype.deleteOrganizations = function()
{
    var orgs = this.getSelectedOrgs();

    if (!orgs || orgs.length == 0)
    {
        return;
    }

    AdminUI.showModalDialogConfirmation("Are you sure you want to delete the selected organizations?",
                                        "Delete",
                                        function()
                                        {
                                            AdminUI.showModalDialogProgress("Deleting Organizations");
        
                                            var processed = 0;
                                            
                                            var errorOrgs = [];
                                        
                                            for (var orgIndex = 0; orgIndex < orgs.length; orgIndex++)
                                            {
                                                var org = orgs[orgIndex];
                                                
                                                var deferred = $.ajax({
                                                                          type: "DELETE",
                                                                          url:  Constants.URL__ORGANIZATIONS + "/" + org
                                                                      });
                                                
                                                deferred.fail(function(xhr, status, error)
                                                {
                                                    errorOrgs.push(org);
                                                });
                                                
                                                deferred.always(function(xhr, status, error)
                                                {
                                                    processed++;
                                                    
                                                    if (processed = orgs.length)
                                                    {
                                                        if (errorOrgs.length > 0)
                                                        {
                                                            var errorDetail = "Error deleting the following organizations:<br/>";
                                                            
                                                            for (var errorIndex = 0; errorIndex < errorOrgs.length; errorIndex++)
                                                            {
                                                                var errorOrg = errorOrgs[errorIndex];
                                                                
                                                                errorDetail += "<br/>" + errorOrg; 
                                                            }
                                                            
                                                            AdminUI.showModalDialogError(errorDetail);
                                                        }
                                                        else
                                                        {
                                                            AdminUI.showModalDialogSuccess();
                                                        }
                                                
                                                        AdminUI.refresh();
                                                    }
                                                });
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
                                  type:        "PUT",
                                  url:         Constants.URL__ORGANIZATIONS + "/" + org,
                                  contentType: "application/json; charset=utf-8",
                                  dataType:    "json",
                                  data:        controlMessage
                              });
        
        deferred.fail(function(xhr, status, error)
        {
            errorOrgs.push(org);
        });
        
        deferred.always(function(xhr, status, error)
        {
            processed++;
             
            if (processed == orgs.length)
            {
                if (errorOrgs.length > 0)
                {
                    var errorDetail = "Error handling the following organizations:<br/>";
                     
                    for (var errorIndex = 0; errorIndex < errorOrgs.length; errorIndex++)
                    {
                        var errorOrg = errorOrgs[errorIndex];
                         
                        errorDetail += "<br/>" + errorOrg; 
                    }
                     
                    AdminUI.showModalDialogError(errorDetail);
                }
                else
                {
                    AdminUI.showModalDialogSuccess();
                }

                AdminUI.refresh();
            }
        });
    }
}

OrganizationsTab.prototype.getSelectedOrgs = function()
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        AdminUI.showModalDialogError("Please select at least one row!");
        
        return null;
    }

    var orgs = [];

    for (var checkedIndex = 0; checkedIndex < checkedRows.length; checkedIndex++)
    {
        orgs.push(checkedRows[checkedIndex].value);
    }

    return orgs;
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
}

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
        AdminUI.showModalDialogError("Error creating the following organization:<br/><br/>" + organizationName);
    });
    
    deferred.always(function(xhr, status, error)
    {
        AdminUI.refresh(); 
    });
}
