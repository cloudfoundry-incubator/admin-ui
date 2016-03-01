
function OrganizationsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ORGANIZATIONS, Constants.URL__ORGANIZATIONS_VIEW_MODEL);
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
                   "width":  "100px",
                   "render": Format.formatOrganizationName
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Status",
                   "width":  "80px",
                   "render": Format.formatOrganizationStatus
               },
               {
                   "title":  "Created",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Updated",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":     "Events Target",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Spaces",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Organization Roles",
                   "width":     "90px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Space Roles",
                   "width":     "90px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "Quota",
                   "width":  "90px",
                   "render": Format.formatQuotaName
               },
               {
                   "title":     "Space Quotas",
                   "width":     "90px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Domains",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Private Service Brokers",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Service Plan Visibilities",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Security Groups",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Total",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Used",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Unused",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Instances",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Services",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Memory",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Disk",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "% CPU",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Memory",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Disk",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Total",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Started",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Stopped",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Pending",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Staged",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Failed",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
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
                       this.createOrganization();
                   },
                   this)
               },
               {
                   text: "Rename",
                   click: $.proxy(function()
                   {
                       this.renameSingleChecked("Rename Organization",
                                                "Managing Organizations",
                                                Constants.URL__ORGANIZATIONS);
                   }, 
                   this)
               },
               {
                   text: "Set Quota",
                   click: $.proxy(function()
                   {
                       this.setOrganizationsQuotas();
                   }, 
                   this)
               },
               {
                   text: "Activate",
                   click: $.proxy(function()
                   {
                       this.updateChecked("Managing Organizations",
                                          Constants.URL__ORGANIZATIONS,
                                          '{"status":"active"}');
                   },
                   this)
               },
               {
                   text: "Suspend",
                   click: $.proxy(function()
                   {
                       this.updateChecked("Managing Organizations",
                                          Constants.URL__ORGANIZATIONS,
                                          '{"status":"suspended"}');
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
                       this.deleteChecked("Are you sure you want to delete the selected organizations and their contained spaces, space quotas, applications, routes, private service brokers, service instances, service bindings, service keys and route bindings?",
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
    
    if (organization.status != null)
    {
        this.addPropertyRow(table, "Status", Format.formatString(organization.status).toUpperCase());
    }
    
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
        this.addFilterRow(table, "Private Service Brokers", Format.formatNumber(row[13]), target, AdminUI.showServiceBrokers);
    }
    
    if (row[14] != null)
    {
        this.addFilterRow(table, "Service Plan Visibilities", Format.formatNumber(row[14]), organization.guid, AdminUI.showServicePlanVisibilities);
    }
    
    if (row[15] != null)
    {
        this.addFilterRow(table, "Security Groups", Format.formatNumber(row[15]), target, AdminUI.showSecurityGroupsSpaces);
    }

    if (row[16] != null)
    {
        this.addFilterRow(table, "Total Routes", Format.formatNumber(row[16]), target, AdminUI.showRoutes);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Used Routes", Format.formatNumber, row[17]);
    this.addRowIfValue(this.addPropertyRow, table, "Unused Routes", Format.formatNumber, row[18]);

    if (row[19] != null)
    {
        this.addFilterRow(table, "Instances Used", Format.formatNumber(row[19]), target, AdminUI.showApplicationInstances);
    }

    if (row[20] != null)
    {
        this.addFilterRow(table, "Services Used", Format.formatNumber(row[20]), target, AdminUI.showServiceInstances);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Memory Used", Format.formatNumber, row[21]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used", Format.formatNumber, row[22]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",  Format.formatNumber, row[23]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[24]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[25]);

    if (row[26] != null)
    {
        this.addFilterRow(table, "Total Apps", Format.formatNumber(row[26]), target, AdminUI.showApplications);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Started Apps", Format.formatNumber, row[27]);
    this.addRowIfValue(this.addPropertyRow, table, "Stopped Apps", Format.formatNumber, row[28]);
    this.addRowIfValue(this.addPropertyRow, table, "Pending Apps", Format.formatNumber, row[29]);
    this.addRowIfValue(this.addPropertyRow, table, "Staged Apps",  Format.formatNumber, row[30]);
    this.addRowIfValue(this.addPropertyRow, table, "Failed Apps",  Format.formatNumber, row[31]);
};

OrganizationsTab.prototype.createOrganization = function()
{
    var dialogContentDiv = $("<div></div>");
    dialogContentDiv.append($("<label>Name: </label>"));
    dialogContentDiv.append($("<input type='text' id='organizationName'>"));

    AdminUI.showModalDialogAction("Create Organization",
                                  dialogContentDiv,
                                  "Create",
                                  "organizationName",
                                  $.proxy(function()
                                  {
                                      var organizationName = $("#organizationName").val();
                                      if (!organizationName)
                                      {
                                          alert("Please input the name first!");
                                          return;
                                      }
                                        
                                      this.doCreateOrganization(organizationName);
                                  }, this));
};

OrganizationsTab.prototype.setOrganizationsQuotas = function()
{
    var organizations = this.getChecked();

    if (!organizations || organizations.length == 0)
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
                                          "quotaSelector",
                                          $.proxy(function()
                                          {
                                              var controlMessage = '{"quota_definition_guid":"' + $("#quotaSelector").val() + '"}';
                                              
                                              this.update("Managing Organizations",
                                                          Constants.URL__ORGANIZATIONS,
                                                          organizations,
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

OrganizationsTab.prototype.doCreateOrganization = function(organizationName)
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
