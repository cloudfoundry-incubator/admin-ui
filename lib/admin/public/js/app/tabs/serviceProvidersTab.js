
function ServiceProvidersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SERVICE_PROVIDERS, Constants.URL__SERVICE_PROVIDERS_VIEW_MODEL);
}

ServiceProvidersTab.prototype = new Tab();

ServiceProvidersTab.prototype.constructor = ServiceProvidersTab;

ServiceProvidersTab.prototype.getInitialSort = function()
{
    return [[1, "asc"], [2, "asc"]];
};

ServiceProvidersTab.prototype.getColumns = function()
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
                   render: Format.formatServiceProviderString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Entity ID",
                   width:  "200px",
                   render: Format.formatServiceProviderString
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
                   title:  "Active",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:     "Version",
                   width:     "100px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               }
           ];
};

ServiceProvidersTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected SAML providers?",
                                                         "Delete",
                                                         "Deleting SAML Providers",
                                                         Constants.URL__SERVICE_PROVIDERS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceProvidersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 3);
};

ServiceProvidersTab.prototype.showDetails = function(table, objects, row)
{
    var identityZone    = objects.identity_zone;
    var serviceProvider = objects.service_provider;

    var first = true;

    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        this.addPropertyRow(table, "Identity Zone ID", Format.formatString(identityZone.id));
        first = false;
    }

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(serviceProvider.name), objects, first);
    this.addPropertyRow(table, "GUID", Format.formatString(serviceProvider.id));
    this.addPropertyRow(table, "Entity ID", Format.formatString(serviceProvider.entity_id));
    this.addPropertyRow(table, "Created", Format.formatDateString(serviceProvider.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, serviceProvider.lastmodified);
    this.addRowIfValue(this.addPropertyRow, table, "Active", Format.formatBoolean, serviceProvider.active);
    this.addPropertyRow(table, "Version", Format.formatNumber(serviceProvider.version));
};
