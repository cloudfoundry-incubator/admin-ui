
function IdentityProvidersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__IDENTITY_PROVIDERS, Constants.URL__IDENTITY_PROVIDERS_VIEW_MODEL);
}

IdentityProvidersTab.prototype = new Tab();

IdentityProvidersTab.prototype.constructor = IdentityProvidersTab;

IdentityProvidersTab.prototype.getInitialSort = function()
{
    return [[1, "asc"], [2, "asc"]];
};

IdentityProvidersTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[2], value);
                                      },
                                      this)
               },
               {
                   title:  "Identity Zone",
                   width:  "300px",
                   render: Format.formatIdentityString
               },
               {
                   title:  "Name",
                   width:  "300px",
                   render: Format.formatIdentityString
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
                   title:  "Origin Key",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Type",
                   width:  "180px",
                   render: Format.formatString
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
               }
           ];
};

IdentityProvidersTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Require Password Change for Users",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Identity Providers",
                                                         Constants.URL__IDENTITY_PROVIDERS,
                                                         "/status",
                                                         '{"requirePasswordChange":true}');
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected identity providers?",
                                                         "Delete",
                                                         "Deleting Identity Providers",
                                                         Constants.URL__IDENTITY_PROVIDERS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

IdentityProvidersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 3);
};

IdentityProvidersTab.prototype.showDetails = function(table, objects, row)
{
    var identityProvider = objects.identity_provider;
    var identityZone     = objects.identity_zone;

    var first = true;

    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        this.addPropertyRow(table, "Identity Zone ID", Format.formatString(identityZone.id));
        first = false;
    }

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(identityProvider.name), objects, first);
    this.addPropertyRow(table, "GUID", Format.formatString(identityProvider.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(identityProvider.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, identityProvider.lastmodified);
    this.addPropertyRow(table, "Origin Key", Format.formatString(identityProvider.origin_key));
    this.addPropertyRow(table, "Type", Format.formatString(identityProvider.type));
    this.addPropertyRow(table, "Active", Format.formatBoolean(identityProvider.active));
    this.addPropertyRow(table, "Version", Format.formatNumber(identityProvider.version));
};
