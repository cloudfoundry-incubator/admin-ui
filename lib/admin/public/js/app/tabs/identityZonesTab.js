
function IdentityZonesTab(id)
{
    Tab.call(this, id, Constants.FILENAME__IDENTITY_ZONES, Constants.URL__IDENTITY_ZONES_VIEW_MODEL);
}

IdentityZonesTab.prototype = new Tab();

IdentityZonesTab.prototype.constructor = IdentityZonesTab;

IdentityZonesTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

IdentityZonesTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[1], value);
                                      },
                                      this)
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatIdentityString
               },
               {
                   title:  "ID",
                   width:  "200px",
                   render: Format.formatIdentityString
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
                   title:  "Subdomain",
                   width:  "180px",
                   render: Format.formatIdentityString
               },
               {
                   title:  "Active",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:     "Version",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Identity Providers",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "SAML Providers",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "MFA Providers",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Clients",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Users",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Groups",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Group Members",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Approvals",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Description",
                   width:  "300px",
                   render: Format.formatStringCleansed
               }
           ];
};

IdentityZonesTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected identity zones?",
                                                         "Delete",
                                                         "Deleting Identity Zones",
                                                         Constants.URL__IDENTITY_ZONES,
                                                         "");
                                  },
                                  this)
               }
           ];
};

IdentityZonesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

IdentityZonesTab.prototype.showDetails = function(table, identityZone, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(identityZone.name), identityZone, true);
    this.addPropertyRow(table, "ID", Format.formatString(identityZone.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(identityZone.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, identityZone.lastmodified);
    this.addPropertyRow(table, "Subdomain", Format.formatString(identityZone.subdomain));
    this.addRowIfValue(this.addPropertyRow, table, "Active", Format.formatBoolean, identityZone.active);
    this.addPropertyRow(table, "Version", Format.formatNumber(identityZone.version));
    this.addRowIfValue(this.addPropertyRow, table, "Description", Format.formatString, identityZone.description);
    this.addFilterRowIfValue(table, "Identity Providers", Format.formatNumber, row[8], identityZone.id, AdminUI.showIdentityProviders);
    this.addFilterRowIfValue(table, "SAML Providers", Format.formatNumber, row[9], identityZone.id, AdminUI.showServiceProviders);
    this.addFilterRowIfValue(table, "MFA Providers", Format.formatNumber, row[10], identityZone.id, AdminUI.showMFAProviders);
    this.addFilterRowIfValue(table, "Clients", Format.formatNumber, row[11], identityZone.id, AdminUI.showClients);
    this.addFilterRowIfValue(table, "Users", Format.formatNumber, row[12], identityZone.id, AdminUI.showUsers);
    this.addFilterRowIfValue(table, "Groups", Format.formatNumber, row[13], identityZone.id, AdminUI.showGroups);
    this.addFilterRowIfValue(table, "Group Members", Format.formatNumber, row[14], identityZone.id, AdminUI.showGroupMembers);
    this.addFilterRowIfValue(table, "Approvals", Format.formatNumber, row[15], identityZone.id, AdminUI.showApprovals);
};
