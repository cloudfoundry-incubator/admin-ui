
function IdentityZonesTab(id)
{
    Tab.call(this, id, Constants.URL__IDENTITY_ZONES_VIEW_MODEL);
}

IdentityZonesTab.prototype = new Tab();

IdentityZonesTab.prototype.constructor = IdentityZonesTab;

IdentityZonesTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

IdentityZonesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatIdentityString
               },
               {
                   "sTitle": "ID",
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
                   "sTitle":  "Subdomain",
                   "sWidth":  "180px",
                   "mRender": Format.formatIdentityString
               },
               {
                   "sTitle":  "Version",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Identity Providers",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Clients",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Users",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Description",
                   "sWidth":  "300px",
                   "mRender": Format.formatStringCleansed
               }
           ];
};

IdentityZonesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

IdentityZonesTab.prototype.showDetails = function(table, identityZone, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatStringCleansed(identityZone.name), identityZone, true);
    this.addPropertyRow(table, "ID", Format.formatStringCleansed(identityZone.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(identityZone.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, identityZone.lastmodified);
    this.addPropertyRow(table, "Subdomain", Format.formatStringCleansed(identityZone.subdomain));
    this.addPropertyRow(table, "Version", Format.formatNumber(identityZone.version));
    this.addRowIfValue(this.addPropertyRow, table, "Description", Format.formatString, identityZone.description);

    if (row[6] != null)
    {
        this.addFilterRow(table, "Identity Providers", Format.formatNumber(row[6]), identityZone.id, AdminUI.showIdentityProviders);
    }
    
    if (row[7] != null)
    {
        this.addFilterRow(table, "Clients", Format.formatNumber(row[7]), identityZone.id, AdminUI.showClients);
    }
    
    if (row[8] != null)
    {
        this.addFilterRow(table, "Users", Format.formatNumber(row[8]), identityZone.id, AdminUI.showUsers);
    }
};
