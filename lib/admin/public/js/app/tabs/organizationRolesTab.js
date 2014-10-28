
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
            "sTitle":  "Organization",
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

OrganizationRolesTab.prototype.clickHandler = function()
{
    this.itemClicked(3, true);
};

OrganizationRolesTab.prototype.showDetails = function(table, objects, row)
{
    organization = objects.organization;
    user_uaa     = objects.user_uaa;
    
    var organizationLink = document.createElement("a");
    $(organizationLink).attr("href", "");
    $(organizationLink).addClass("tableLink");
    $(organizationLink).html(Format.formatStringCleansed(organization.name));
    $(organizationLink).click(function()
    {
        AdminUI.showOrganizations(organization.name);

        return false;
    });
    
    var details = document.createElement("div");
    $(details).append(organizationLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "Organization", details, true);
    
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
    
    this.addPropertyRow(table, "Role", Format.formatString(row[2]));
};
