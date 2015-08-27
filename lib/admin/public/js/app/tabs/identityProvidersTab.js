
function IdentityProvidersTab(id)
{
    Tab.call(this, id, Constants.URL__IDENTITY_PROVIDERS_VIEW_MODEL);
}

IdentityProvidersTab.prototype = new Tab();

IdentityProvidersTab.prototype.constructor = IdentityProvidersTab;

IdentityProvidersTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

IdentityProvidersTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Identity Zone",
                   "sWidth":  "300px",
                   "mRender": Format.formatIdentityString
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "300px",
                   "mRender": Format.formatIdentityString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatIdentityString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Origin Key",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Type",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Active",
                   "sWidth":  "200px",
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Version",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
};

IdentityProvidersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

IdentityProvidersTab.prototype.showDetails = function(table, objects, row)
{
    var identityProvider = objects.identity_provider;
    var identityZone     = objects.identity_zone;
    
    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones);
    }
    
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(identityProvider.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(identityProvider.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(identityProvider.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, identityProvider.lastmodified);
    this.addPropertyRow(table, "Origin Key", Format.formatString(identityProvider.origin_key));
    this.addPropertyRow(table, "Type", Format.formatString(identityProvider.type));
    this.addPropertyRow(table, "Active", Format.formatBoolean(identityProvider.active));
    this.addPropertyRow(table, "Version", Format.formatNumber(identityProvider.version));
};
