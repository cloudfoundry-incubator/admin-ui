
function IdentityProvidersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__IDENTITY_PROVIDERS, Constants.URL__IDENTITY_PROVIDERS_VIEW_MODEL);
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
                   "title":  "Identity Zone",
                   "width":  "300px",
                   "render": Format.formatIdentityString
               },
               {
                   "title":  "Name",
                   "width":  "300px",
                   "render": Format.formatIdentityString
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Created",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Updated",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Origin Key",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Type",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Active",
                   "width":  "10px",
                   "render": Format.formatBoolean
               },
               {
                   "title":     "Version",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Clients",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
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
    
    if (row[9] != null)
    {
        this.addFilterRow(table, "Clients", Format.formatNumber(row[9]), identityProvider.id, AdminUI.showClients);
    }
};
