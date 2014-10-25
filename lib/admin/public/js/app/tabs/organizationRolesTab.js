
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

OrganizationRolesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1, 3, 4);
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
        AdminUI.showOrganizations(organization.name);

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
        AdminUI.showUsers(user_uaa.username);

        return false;
    });

    this.addRow(table, "User", userLink);
    
    this.addPropertyRow(table, "User GUID", Format.formatString(user_uaa.id));
    
    this.addPropertyRow(table, "Role", Format.formatString(row[4]));
};
