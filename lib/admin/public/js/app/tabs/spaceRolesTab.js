
function SpaceRolesTab(id)
{
    Tab.call(this, id, Constants.URL__SPACE_ROLES_VIEW_MODEL);
}

SpaceRolesTab.prototype = new Tab();

SpaceRolesTab.prototype.constructor = SpaceRolesTab;

SpaceRolesTab.prototype.getInitialSort = function()
{
    return [[2, "asc"]];
};

SpaceRolesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":    "&nbsp;",
                   "sWidth":    "2px",
                   "sClass":    "cellCenterAlign",
                   "bSortable": false,
                   "mRender":   function(value, type)
                   {
                       return "<input type='checkbox' value='" + value + "' onclick='SpaceRolesTab.prototype.checkboxClickHandler(event)'></input>";
                   }
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatSpaceName
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "200px",
                   "mRender": Format.formatTarget
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

SpaceRolesTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteSpaceRoles();
                   },
                   this)
               }
           ];
};

SpaceRolesTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

SpaceRolesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

SpaceRolesTab.prototype.showDetails = function(table, objects, row)
{
    var organization = objects.organization;
    var space        = objects.space;
    var user_uaa     = objects.user_uaa;
    
    if (organization != null)
    {
        var spaceLink = document.createElement("a");
        $(spaceLink).attr("href", "");
        $(spaceLink).addClass("tableLink");
        $(spaceLink).html(Format.formatStringCleansed(space.name));
        $(spaceLink).click(function()
        {
            AdminUI.showSpaces(row[3]);
    
            return false;
        });
    
        var details = document.createElement("div");
        $(details).append(spaceLink);
        $(details).append(this.createJSONDetailsLink(objects));
        
        this.addRow(table, "Space", details, true);
        
        this.addPropertyRow(table, "Space GUID", Format.formatString(space.guid));
        
        var organizationLink = document.createElement("a");
        $(organizationLink).attr("href", "");
        $(organizationLink).addClass("tableLink");
        $(organizationLink).html(Format.formatStringCleansed(organization.name));
        $(organizationLink).click(function()
        {
            AdminUI.showOrganizations(organization.name);
    
            return false;
        });
    
        this.addRow(table, "Organization", organizationLink);
    }
    else
    {
        this.addJSONDetailsLinkRow(table, "Space", Format.formatString(space.name), objects, true);
        this.addPropertyRow(table, "Space GUID", Format.formatString(space.guid));
    }
    
    var userLink = document.createElement("a");
    $(userLink).attr("href", "");
    $(userLink).addClass("tableLink");
    $(userLink).html(Format.formatStringCleansed(user_uaa.username));
    $(userLink).click(function()
    {
        AdminUI.showUsers(user_uaa.username);

        return false;
    });

    this.addRow(table, "User", userLink);
    
    this.addPropertyRow(table, "User GUID", Format.formatString(user_uaa.id));
    
    this.addPropertyRow(table, "Role", Format.formatString(row[6]));
};

SpaceRolesTab.prototype.deleteSpaceRoles = function()
{
    var spaceRoles = this.getSelectedSpaceRoles();

    if (!spaceRoles || spaceRoles.length == 0)
    {
        return;
    }

    AdminUI.showModalDialogConfirmation("Are you sure you want to delete the selected space roles?",
                                        "Delete",
                                        function()
                                        {
                                            AdminUI.showModalDialogProgress("Deleting Space Roles");
        
                                            var processed = 0;
                                            
                                            var errorSpaceRoles = [];
                                        
                                            for (var spaceRoleIndex = 0; spaceRoleIndex < spaceRoles.length; spaceRoleIndex++)
                                            {
                                                var spaceRole = spaceRoles[spaceRoleIndex];
                                                
                                                var deferred = $.ajax({
                                                                          type: "DELETE",
                                                                          url:  Constants.URL__SPACES + "/" + spaceRole
                                                                      });
                                                
                                                deferred.fail(function(xhr, status, error)
                                                {
                                                    errorSpaceRoles.push(spaceRole);
                                                });
                                                
                                                deferred.always(function(xhr, status, error)
                                                {
                                                    processed++;
                                                    
                                                    if (processed = spaceRoles.length)
                                                    {
                                                        if (errorSpaceRoles.length > 0)
                                                        {
                                                            var errorDetail = "Error deleting the following space roles:<br/>";
                                                            
                                                            for (var errorIndex = 0; errorIndex < errorSpaceRoles.length; errorIndex++)
                                                            {
                                                                var errorSpaceRole = errorSpaceRoles[errorIndex];
                                                                
                                                                errorDetail += "<br/>" + errorSpaceRole; 
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

SpaceRolesTab.prototype.getSelectedSpaceRoles = function()
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        AdminUI.showModalDialogError("Please select at least one row!");
        
        return null;
    }

    var spaceRoles = [];

    for (var checkedIndex = 0; checkedIndex < checkedRows.length; checkedIndex++)
    {
        spaceRoles.push(checkedRows[checkedIndex].value);
    }

    return spaceRoles;
};
