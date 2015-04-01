
function OrganizationRolesTab(id)
{
    Tab.call(this, id, Constants.URL__ORGANIZATION_ROLES_VIEW_MODEL);
}

OrganizationRolesTab.prototype = new Tab();

OrganizationRolesTab.prototype.constructor = OrganizationRolesTab;

OrganizationRolesTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
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
                       
                       return Tab.prototype.formatCheckbox(name, value);
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

OrganizationRolesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

OrganizationRolesTab.prototype.showDetails = function(table, objects, row)
{
    var organization = objects.organization;
    var user_uaa     = objects.user_uaa;
    
    var organizationLink = this.createFilterLink(Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    var details = document.createElement("div");
    $(details).append(organizationLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "Organization", details, true);
    
    this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    
    this.addFilterRow(table, "User", Format.formatStringCleansed(user_uaa.username), user_uaa.id, AdminUI.showUsers);
    
    this.addPropertyRow(table, "User GUID", Format.formatString(user_uaa.id));
    
    this.addPropertyRow(table, "Role", Format.formatString(row[5]));
};

OrganizationRolesTab.prototype.deleteOrganizationRoles = function()
{
    var organizationRoles = this.getChecked();

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
                                                                          rolePath: organizationRole.name
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
