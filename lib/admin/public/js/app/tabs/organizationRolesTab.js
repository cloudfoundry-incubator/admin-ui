
function OrganizationRolesTab(id)
{
    Tab.call(this, id, Constants.URL__ORGANIZATION_ROLES_VIEW_MODEL);
}

OrganizationRolesTab.prototype = new Tab();

OrganizationRolesTab.prototype.constructor = OrganizationRolesTab;

OrganizationRolesTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

OrganizationRolesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":    "&nbsp;",
                   "sWidth":    "2px",
                   "sClass":    "cellCenterAlign",
                   "bSortable": false,
                   "mRender":   function(value, type, item)
                   {
                       var name = item[1] + "/" + item[5] + "/" + item[3];
                       
                       return "<input type='checkbox' name='" + escape(name) + "' value='" + value + "' onclick='OrganizationRolesTab.prototype.checkboxClickHandler(event)'></input>";
                   }
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatOrganizationName
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle": "Name",
                   "sWidth": "200px",
                   "mRender": Format.formatUserString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle": "Role",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               }
           ];
};

OrganizationRolesTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteOrganizationRoles();
                   },
                   this)
               }
           ];
};

OrganizationRolesTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

OrganizationRolesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

OrganizationRolesTab.prototype.showDetails = function(table, objects, row)
{
    var organization = objects.organization;
    var user_uaa     = objects.user_uaa;
    
    var organizationLink = document.createElement("a");
    $(organizationLink).attr("href", "");
    $(organizationLink).addClass("tableLink");
    $(organizationLink).html(Format.formatStringCleansed(organization.name));
    $(organizationLink).click(function()
    {
        AdminUI.showOrganizations(organization.guid);

        return false;
    });
    
    var details = document.createElement("div");
    $(details).append(organizationLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "Organization", details, true);
    
    this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    
    var userLink = document.createElement("a");
    $(userLink).attr("href", "");
    $(userLink).addClass("tableLink");
    $(userLink).html(Format.formatStringCleansed(user_uaa.username));
    $(userLink).click(function()
    {
        AdminUI.showUsers(user_uaa.id);

        return false;
    });

    this.addRow(table, "User", userLink);
    
    this.addPropertyRow(table, "User GUID", Format.formatString(user_uaa.id));
    
    this.addPropertyRow(table, "Role", Format.formatString(row[5]));
};

OrganizationRolesTab.prototype.deleteOrganizationRoles = function()
{
    var organizationRoles = this.getSelectedOrganizationRoles();

    if (!organizationRoles || organizationRoles.length == 0)
    {
        return;
    }

    AdminUI.showModalDialogConfirmation("Are you sure you want to delete the selected organization roles?",
                                        "Delete",
                                        function()
                                        {
                                            AdminUI.showModalDialogProgress("Deleting Organization Roles");
        
                                            var processed = 0;
                                            
                                            var errorOrganizationRoles = [];
                                        
                                            for (var organizationRoleIndex = 0; organizationRoleIndex < organizationRoles.length; organizationRoleIndex++)
                                            {
                                                var organizationRole = organizationRoles[organizationRoleIndex];
                                                
                                                var deferred = $.ajax({
                                                                          type:     "DELETE",
                                                                          url:      Constants.URL__ORGANIZATIONS + "/" + organizationRole.guid,
                                                                          // Need organization role path inside the fail method
                                                                          rolePath: organizationRole.path
                                                                      });
                                                
                                                deferred.fail(function(xhr, status, error)
                                                {
                                                    errorOrganizationRoles.push({
                                                                                    label: this.rolePath,
                                                                                    xhr:   xhr
                                                                                });
                                                });
                                                
                                                deferred.always(function(xhr, status, error)
                                                {
                                                    processed++;
                                                    
                                                    if (processed == organizationRoles.length)
                                                    {
                                                        if (errorOrganizationRoles.length > 0)
                                                        {
                                                            AdminUI.showModalDialogErrorTable(errorOrganizationRoles);
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

OrganizationRolesTab.prototype.getSelectedOrganizationRoles = function()
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        AdminUI.showModalDialogError("Please select at least one row!");
        
        return null;
    }

    var organizationRoles = [];

    for (var checkedIndex = 0; checkedIndex < checkedRows.length; checkedIndex++)
    {
        var checkedRow = checkedRows[checkedIndex];
        
        organizationRoles.push({
                                   path: unescape(checkedRow.name),
                                   guid: checkedRow.value
                               });
    }

    return organizationRoles;
};
