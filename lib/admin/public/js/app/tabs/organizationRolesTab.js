
function OrganizationRolesTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ORGANIZATION_ROLES, Constants.URL__ORGANIZATION_ROLES_VIEW_MODEL);
}

OrganizationRolesTab.prototype = new Tab();

OrganizationRolesTab.prototype.constructor = OrganizationRolesTab;

OrganizationRolesTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var name = item[5] + "/" + item[1] + "/" + item[7];

                                          return this.formatCheckbox(this.id, name, value);
                                      },
                                      this)
               },
               {
                   title:  "Role",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatOrganizationName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatUserString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               }
           ];
};

OrganizationRolesTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected organization roles?",
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
    var role         = objects.role;
    var user         = objects.user_uaa;

    this.addJSONDetailsLinkRow(table, "Role", Format.formatString(row[1]), objects, true);
    this.addRowIfValue(this.addPropertyRow, table, "GUID", Format.formatString, role.role_guid);
    this.addRowIfValue(this.addPropertyRow, table, "Created", Format.formatDateString, role.created_at);
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, role.updated_at);
    this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    this.addFilterRow(table, "User", Format.formatStringCleansed(user.username), user.id, AdminUI.showUsers);
    this.addPropertyRow(table, "User GUID", Format.formatString(user.id));
};
