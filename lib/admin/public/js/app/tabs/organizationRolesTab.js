
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
                   "title":     Tab.prototype.formatCheckboxHeader(this.id),
                   "type":      "html",
                   "width":     "2px",
                   "orderable": false,
                   "render":    $.proxy(function(value, type, item)
                   {
                       var name = item[1] + "/" + item[5] + "/" + item[3];
                       
                       return this.formatCheckbox(name, value);
                   },
                   this),
               },
               {
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatOrganizationName
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatUserString
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Role",
                   "width":  "200px",
                   "render": Format.formatString
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
                       this.deleteChecked("Are you sure you want to delete the selected organization roles?",
                                          "Delete",
                                          "Deleting Organization Roles",
                                          Constants.URL__ORGANIZATIONS,
                                          "");
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
