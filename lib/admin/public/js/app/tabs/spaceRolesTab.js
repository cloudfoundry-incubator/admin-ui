
function SpaceRolesTab(id)
{
    Tab.call(this, id, Constants.URL__SPACE_ROLES_VIEW_MODEL);
}

SpaceRolesTab.prototype = new Tab();

SpaceRolesTab.prototype.constructor = SpaceRolesTab;

SpaceRolesTab.prototype.getColumns = function()
{
    return [
        {
            "sTitle":  "Space",
            "sWidth":  "200px",
            "mRender": Format.formatStringCleansed
        },
        {
            "sTitle":  "Target",
            "sWidth":  "200px",
            "mRender": Format.formatStringCleansed
        },
        {
            "sTitle": "Username",
            "sWidth": "200px",
            "mRender": Format.formatStringCleansed
        },
        {
            "sTitle": "Role",
            "sWidth": "200px",
            "mRender": Format.formatString
        }        
    ];
};

SpaceRolesTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

SpaceRolesTab.prototype.clickHandler = function()
{
    this.itemClicked(4, true);
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
            AdminUI.showSpaces(row[1]);
    
            return false;
        });
    
        var details = document.createElement("div");
        $(details).append(spaceLink);
        $(details).append(this.createJSONDetailsLink(objects));
        
        this.addRow(table, "Space", details, true);
        
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

    this.addRow(table, "Username", userLink);
    
    this.addPropertyRow(table, "Role", Format.formatString(row[3]));
};
