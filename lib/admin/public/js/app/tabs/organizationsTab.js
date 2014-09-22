
function OrganizationsTab(id)
{
    Tab.call(this, id, Constants.URL__ORGANIZATIONS_VIEW_MODEL);
}

OrganizationsTab.prototype = new Tab();

OrganizationsTab.prototype.constructor = OrganizationsTab;

OrganizationsTab.prototype.getInitialSort = function()
{
    return [[5, "desc"]];
};

OrganizationsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "&nbsp;",
                    "sWidth": "2px",
                   "sClass": "cellCenterAlign",
                   "bSortable": false,
                   "mRender": function(value, type)
                   {
                       return '<input type="checkbox" value="' + value + '" onclick="OrganizationsTab.prototype.checkboxClickHandler(event)"></input>';
                   }
               },
               {
                   "sTitle": "Name",
                   "sWidth": "100px",
                   "mRender": Format.formatOrganizationName
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
                   "mRender": Format.formatString
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
                       this.manageOrganizations('activate');
                   },
                   this)
               },
               {
                   text: "Suspend",
                   click: $.proxy(function()
                   {
                       this.manageOrganizations('suspend');
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
    this.itemClicked(26, true);
};

OrganizationsTab.prototype.showDetails = function(table, organization, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(organization.name), organization, true);

    this.addPropertyRow(table, "Status", Format.formatString(organization.status).toUpperCase());
    this.addPropertyRow(table, "Created", Format.formatDateString(organization.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, organization.updated_at);
    this.addPropertyRow(table, "Billing Enabled", Format.formatString(organization.billing_enabled));

    if (row[5] != null)
    {
        var spacesLink = document.createElement("a");
        $(spacesLink).attr("href", "");
        $(spacesLink).addClass("tableLink");
        $(spacesLink).html(Format.formatNumber(row[5]));
        $(spacesLink).click(function()
        {
            AdminUI.showSpaces(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Spaces", spacesLink);
    }

    if (row[6] != null)
    {
        var organizationRolesLink = document.createElement("a");
        $(organizationRolesLink).attr("href", "");
        $(organizationRolesLink).addClass("tableLink");
        $(organizationRolesLink).html(Format.formatNumber(row[6]));
        $(organizationRolesLink).click(function()
        {
            AdminUI.showOrganizationRoles(Format.formatString(organization.name));
    
            return false;
        });
        this.addRow(table, "Organization Roles", organizationRolesLink);
    }

    if (row[7] != null)
    {
        var spaceRolesLink = document.createElement("a");
        $(spaceRolesLink).attr("href", "");
        $(spaceRolesLink).addClass("tableLink");
        $(spaceRolesLink).html(Format.formatNumber(row[7]));
        $(spaceRolesLink).click(function()
        {
            AdminUI.showSpaceRoles(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Space Roles", spaceRolesLink);
    }
    
    if (row[8] != null)
    {
        var quotaLink = document.createElement("a");
        $(quotaLink).attr("href", "");
        $(quotaLink).addClass("tableLink");
        $(quotaLink).html(Format.formatString(row[8]));
        $(quotaLink).click(function()
        {
            AdminUI.showQuotas(row[8]);
    
            return false;
        });
        this.addRow(table, "Quota", quotaLink);
    }

    if (row[9] != null)
    {
        var domainsLink = document.createElement("a");
        $(domainsLink).attr("href", "");
        $(domainsLink).addClass("tableLink");
        $(domainsLink).html(Format.formatNumber(row[9]));
        $(domainsLink).click(function()
        {
            AdminUI.showDomains(Format.formatString(organization.name));
    
            return false;
        });
        this.addRow(table, "Domains", domainsLink);
    }
    
    if (row[10] != null)
    {
        var routesLink = document.createElement("a");
        $(routesLink).attr("href", "");
        $(routesLink).addClass("tableLink");
        $(routesLink).html(Format.formatNumber(row[10]));
        $(routesLink).click(function()
        {
            AdminUI.showRoutes(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Total Routes", routesLink);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Used Routes", Format.formatNumber, row[11]);
    this.addRowIfValue(this.addPropertyRow, table, "Unused Routes", Format.formatNumber, row[12]);

    if (row[13] != null)
    {
        var instancesLink = document.createElement("a");
        $(instancesLink).attr("href", "");
        $(instancesLink).addClass("tableLink");
        $(instancesLink).html(Format.formatNumber(row[13]));
        $(instancesLink).click(function()
        {
            AdminUI.showApplications(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Instances Used", instancesLink);
    }

    if (row[14] != null)
    {
        var servicesLink = document.createElement("a");
        $(servicesLink).attr("href", "");
        $(servicesLink).addClass("tableLink");
        $(servicesLink).html(Format.formatNumber(row[14]));
        $(servicesLink).click(function()
        {
            AdminUI.showServiceInstances(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Services Used", servicesLink);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Memory Used", Format.formatNumber, row[15]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used", Format.formatNumber, row[16]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",  Format.formatNumber, row[17]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[18]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[19]);

    if (row[20] != null)
    {
        var appsLink = document.createElement("a");
        $(appsLink).attr("href", "");
        $(appsLink).addClass("tableLink");
        $(appsLink).html(Format.formatNumber(row[20]));
        $(appsLink).click(function()
        {
            AdminUI.showApplications(Format.formatString(organization.name) + "/");
    
            return false;
        });
        this.addRow(table, "Total Apps", appsLink);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Started Apps", Format.formatNumber, row[21]);
    this.addRowIfValue(this.addPropertyRow, table, "Stopped Apps", Format.formatNumber, row[22]);
    this.addRowIfValue(this.addPropertyRow, table, "Pending Apps", Format.formatNumber, row[23]);
    this.addRowIfValue(this.addPropertyRow, table, "Staged Apps",  Format.formatNumber, row[24]);
    this.addRowIfValue(this.addPropertyRow, table, "Failed Apps",  Format.formatNumber, row[25]);
};

OrganizationsTab.prototype.manageOrganizations = function(type)
{
    if (!this.getSelectedOrgs())
    {
        return;
    }

    var control_message = '';

    if (type == 'activate')
    {
        if (!confirm('Are you sure you want to activate the selected organizations?'))
        {
            return;
        }

        control_message = '{"status":"active"}';
    }
    else if (type == 'suspend')
    {
        if (!confirm('Are you sure you want to suspend the selected organizations?'))
        {
            return;
        }

        control_message = '{"status":"suspended"}';
    }

    this.updateOrganizations(control_message);
}

OrganizationsTab.prototype.manageQuotas = function()
{
    if (!this.getSelectedOrgs())
    {
        return;
    }
    
    var organizationTab = this;

    var deferred = $.ajax({ 
                              "dataType": 'json',
                              "type": "GET",
                               "url": Constants.URL__QUOTAS_VIEW_MODEL,
                               "async": false
                          });

    deferred.done(function(result, status)
    {            
        if (result.items.connected)
        {
            quotas = result.items.items;
            var dialogContentDiv = $('<div class="quota_management_div"></div>');
            dialogContentDiv.append($('<label>Select a quota: </label>'));

            var selector = $('<select id="quotaSelector"></select>');

            for (var step = 0; step < quotas.length; step ++)
            {
                var quota = quotas[step][9];
                selector.append($('<option value="' + quota.guid + '">' + quota.name + '</quota>'));
            }

            dialogContentDiv.append(selector);

            AdminUI.showModalDialog({
                                        "body": dialogContentDiv,
                                        "title": "Set quota for organization",
                                        "height": 60,
                                        "buttons": 
                                        [
                                            {
                                                "name": "Set",
                                                "callback": $.proxy(function()
                                                {
                                                    AdminUI.closeModalDialog();
                                                    organizationTab.setQuota($('#quotaSelector').val());
                                                }, organizationTab)
                                            },
                                            {
                                                "name": "Cancel",
                                                "callback": function()
                                                {
                                                    AdminUI.closeModalDialog();
                                                }
                                            }
                                        ]
                                    });
        }
        else
        {
            var error = "Error retrieving quota definitions";
            
            if (result.items.error)
            {
                error += ".  Error: " + result.items.error;
            }    

            alert(error);
        }
    });
    
    deferred.fail(function(xhr, status, error)
    {
        if (xhr.status == 303)
        {
            window.location.href = Constants.URL__LOGIN;
        }
        else
        {
            alert("Unable to retrieve quota definitions.  Error: " + error);
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

    if (!confirm("Are you sure you want to delete the selected organizations?"))
    {
        return;
    }

    AdminUI.showModalDialog({ "body": $('<label>"Deleting organizations, please wait..."</label>') });

    var error_orgs = [];

    for (var step = 0; step < orgs.length; step ++)
    {
        var org = orgs[step];
        var url = "/organizations/" + org;
        $.ajax({
            type: 'DELETE',
            async: false,
            url: url,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {},
            error: function (msg)
            {
                error_orgs.push(org);
            }
        });
    }

    AdminUI.closeModalDialog();

    if (error_orgs.length > 0)
    {
        alert("Error deleting the following organizations:\n" + error_orgs);
    }
    else
    {
        alert("Organizations successfully deleted.");
    }

    AdminUI.refresh();
};

OrganizationsTab.prototype.updateOrganizations = function(control_message)
{
    AdminUI.showModalDialog({ "body": $('<label>"Performing operation, please wait..."</label>') });

    var error_orgs = [];

    var orgs = this.getSelectedOrgs();

    for (var step = 0; step < orgs.length; step ++)
    {
        var org = orgs[step];

        var type = "PUT";
        var url = Constants.URL__ORGANIZATIONS + "/" + org;

        var successCallback = function(data){};
        var errorCallback = function(msg)
        {
            error_orgs.push(org);
        };

        this.sendSyncRequest(type, url, control_message, successCallback, errorCallback);
    }

    AdminUI.closeModalDialog();

    if (error_orgs.length > 0)
    {
        alert("Error handling the following organizations:\n" + error_orgs);
    }
    else
    {
        // Todos: we need to implement a polling backend service to get the latest app data in the future
        alert("The operation finished without error.\nPlease refresh the page later for the updated result.");
    }

    AdminUI.refresh();
}

OrganizationsTab.prototype.setQuota = function(quota_id)
{
    var control_message = '{"quota_definition_guid":"' + quota_id + '"}';
    this.updateOrganizations(control_message);
};

OrganizationsTab.prototype.sendSyncRequest = function(type, url, body, successCallback, errorCallback)
{
    $.ajax({
        type: type,
        async: false,
        url: url,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: body,
        success: successCallback,
        error: errorCallback
    });
};

OrganizationsTab.prototype.getSelectedOrgs = function()
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        alert("Please select at least one row!");
        return null;
    }

    var orgs = [];

    for (var step = 0; step < checkedRows.length; step ++)
    {
        orgs.push(checkedRows[step].value);
    }

    return orgs;
};

OrganizationsTab.prototype.createOrg = function()
{
    var dialogContentDiv = $('<div class="organization_creation_div"></div>');
    dialogContentDiv.append($('<label>Name: </label>'));
    dialogContentDiv.append($('<input type="text" id="organizationName">'))

    AdminUI.showModalDialog(
        {
            "body": dialogContentDiv,
            "title": "Create new organization",
            "height": 60,
            "buttons": [
                {
                    "name": "Create",
                    "callback": $.proxy(function()
                    {
                        var name = $('#organizationName').val();
                        if (!name)
                        {
                            alert("Please input the name of the organization first!");
                            return;
                        }
                        AdminUI.closeModalDialog();
                        this.doCreateOrg(name);
                    }, this)
                },
                {
                    "name": "Cancel",
                    "callback": function()
                    {
                        AdminUI.closeModalDialog();
                    }
                }
            ]
        });
}

OrganizationsTab.prototype.doCreateOrg = function(organizationName)
{
    AdminUI.showModalDialog({ "body": $('<label>"Performing operation, please wait..."</label>') });

    var type = "POST";
    var url = "/organizations";
    var successCallback = function(data){};
    var error_flag = false;
    var errorCallback = function(msg)
    {
        error_flag = true;
    };

    this.sendSyncRequest(type, url, '{"name":"' + organizationName + '"}', successCallback, errorCallback);

    AdminUI.closeModalDialog();

    if (error_flag)
    {
        alert("Error handling the following organization:\n" + organizationName);
    }
    else
    {
        // Todos: we need to implement a polling backend service to get the latest app data in the future
        alert("The operation finished without error.\nPlease refresh the page later for the updated result.");
    }

    AdminUI.refresh();
}
