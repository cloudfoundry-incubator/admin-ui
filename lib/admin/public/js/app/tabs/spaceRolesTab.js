
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
            "sTitle":  "Name",
            "sWidth":  "200px",
            "mRender": Format.formatStringCleansed
        },
        {
            "sTitle": "GUID",
            "sWidth": "200px",
            "mRender": Format.formatString
        },
        {
            "sTitle":  "Target",
            "sWidth":  "200px",
            "mRender": Format.formatStringCleansed
        },
        {
            "sTitle": "Name",
            "sWidth": "200px",
            "mRender": Format.formatStringCleansed
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

SpaceRolesTab.prototype.clickHandler = function()
{
    this.itemClicked(6, -1);
};

SpaceRolesTab.prototype.showDetails = function(table, objects, row)
{
    organization = objects.organization;
    space        = objects.space;
    user_uaa     = objects.user_uaa;
    
    if (organization != null)
    {
        var spaceLink = document.createElement("a");
        $(spaceLink).attr("href", "");
        $(spaceLink).addClass("tableLink");
        $(spaceLink).html(Format.formatStringCleansed(space.name));
        $(spaceLink).click(function()
        {
            AdminUI.showSpaces(row[2]);
    
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
    
    this.addPropertyRow(table, "Role", Format.formatString(row[5]));
};
