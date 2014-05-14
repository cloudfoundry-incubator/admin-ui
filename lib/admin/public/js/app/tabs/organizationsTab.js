
function OrganizationsTab(id)
{
    this.url = Constants.URL__ORGANIZATIONS_TAB;
    
    this.serverSide = true;
    
    Tab.call(this, id);
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
                   "sTitle":  "Developers",
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

               }
           ];
};

OrganizationsTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

OrganizationsTab.prototype.clickHandler = function()
{
    this.itemClicked(24, true);
};

OrganizationsTab.prototype.showDetails = function(table, organization, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(organization.name), organization, true);

    this.addPropertyRow(table, "Status",          Format.formatString(organization.status).toUpperCase());
    this.addPropertyRow(table, "Created",         Format.formatDateString(organization.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, organization.updated_at);
    this.addPropertyRow(table, "Billing Enabled", Format.formatString(organization.billing_enabled));

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

    var developersLink = document.createElement("a");
    $(developersLink).attr("href", "");
    $(developersLink).addClass("tableLink");
    $(developersLink).html(Format.formatNumber(row[6]));
    $(developersLink).click(function()
    {
        AdminUI.showDevelopers(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Developers", developersLink);

    var quotaLink = document.createElement("a");
    $(quotaLink).attr("href", "");
    $(quotaLink).addClass("tableLink");
    $(quotaLink).html(Format.formatString(row[7]));
    $(quotaLink).click(function()
    {
        AdminUI.showQuotas(row[7]);

        return false;
    });
    this.addRow(table, "Quota", quotaLink);

    var routesLink = document.createElement("a");
    $(routesLink).attr("href", "");
    $(routesLink).addClass("tableLink");
    $(routesLink).html(Format.formatNumber(row[8]));
    $(routesLink).click(function()
    {
        AdminUI.showRoutes(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Total Routes", routesLink);

    this.addPropertyRow(table, "Used Routes", Format.formatNumber(row[9]));
    this.addPropertyRow(table, "Unused Routes", Format.formatNumber(row[10]));

    var instancesLink = document.createElement("a");
    $(instancesLink).attr("href", "");
    $(instancesLink).addClass("tableLink");
    $(instancesLink).html(Format.formatNumber(row[11]));
    $(instancesLink).click(function()
    {
        AdminUI.showApplications(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Instances Used", instancesLink);

    var servicesLink = document.createElement("a");
    $(servicesLink).attr("href", "");
    $(servicesLink).addClass("tableLink");
    $(servicesLink).html(Format.formatNumber(row[12]));
    $(servicesLink).click(function()
    {
        AdminUI.showServiceInstances(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Services Used", servicesLink);

    this.addPropertyRow(table, "Memory Used",     Format.formatNumber(row[13]));
    this.addPropertyRow(table, "Disk Used",       Format.formatNumber(row[14]));
    this.addPropertyRow(table, "CPU Used",        Format.formatNumber(row[15]));
    this.addPropertyRow(table, "Memory Reserved", Format.formatNumber(row[16]));
    this.addPropertyRow(table, "Disk Reserved",   Format.formatNumber(row[17]));

    var appsLink = document.createElement("a");
    $(appsLink).attr("href", "");
    $(appsLink).addClass("tableLink");
    $(appsLink).html(Format.formatNumber(row[18]));
    $(appsLink).click(function()
    {
        AdminUI.showApplications(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Total Apps", appsLink);

    this.addPropertyRow(table, "Started Apps",    Format.formatNumber(row[19]));
    this.addPropertyRow(table, "Stopped Apps",    Format.formatNumber(row[20]));
    this.addPropertyRow(table, "Pending Apps",    Format.formatNumber(row[21]));
    this.addPropertyRow(table, "Staged Apps",     Format.formatNumber(row[22]));
    this.addPropertyRow(table, "Failed Apps",     Format.formatNumber(row[23]));
};

OrganizationsTab.prototype.showOrganizations = function(filter)
{
    AdminUI.setTabSelected(this.id);

    this.hideDetails();

    this.table.fnFilter(filter);
    
    this.show();
};

OrganizationsTab.prototype.manageQuotas = function()
{
    if (!this.getSelectedOrgs())
    {
        return;
    }

    var quotasDeferred = Data.get(Constants.URL__QUOTA_DEFINITIONS, false);

    $.when(quotasDeferred).done($.proxy(function(quotasResult)
    {
        var quotas = quotasResult.response.items;
        var dialogContentDiv = $('<div class="quota_management_div"></div>');
        dialogContentDiv.append($('<label>Select a qutoa: </label>'));

        var selector = $('<select id="quotaSelector"></select>');

        for (var step = 0; step < quotas.length; step ++)
        {
            var quota = quotas[step];
            selector.append($('<option value="' + quota.guid + '">' + quota.name + '</quota>'));
        }

        dialogContentDiv.append(selector);

        AdminUI.showModalDialog(
            {
                "body": dialogContentDiv,
                "title": "Set quota for organization",
                "height": 60,
                "buttons": [
                    {
                        "name": "Set",
                        "callback": $.proxy(function()
                        {
                            AdminUI.closeModalDialog();
                            this.setQuota($('#quotaSelector').val());
                        }, this)
                    },
                    {
                        "name": "Cancel",
                        "callback": function(){
                            AdminUI.closeModalDialog();
                        }
                    }
                ]
            });
    }, this));
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
}

OrganizationsTab.prototype.setQuota = function(quota_id)
{

    AdminUI.showModalDialog({ "body": $('<label>"Performing operation, please wait..."</label>') });

    var error_orgs = [];

    var orgs = this.getSelectedOrgs();

    for (var step = 0; step < orgs.length; step ++)
    {
        var org = orgs[step];

        var type = "PUT";
        var url = "/organizations/" + org;

        var successCallback = function(data){};
        var errorCallback = function(msg)
        {
            error_orgs.push(org);
        };

        this.sendSyncRequest(type, url, '{"quota_definition_guid":"' + quota_id + '"}', successCallback, errorCallback);
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
