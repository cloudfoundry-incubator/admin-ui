
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
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatIdentityString
               },
               {
                   "title":  "ID",
                   "width":  "200px",
                   "render": Format.formatIdentityString
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
                   "title":  "Subdomain",
                   "width":  "180px",
                   "render": Format.formatIdentityString
               },
               {
                   "title":     "Version",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Identity Providers",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Clients",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Users",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "Description",
                   "width":  "300px",
                   "render": Format.formatStringCleansed
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
    this.addPropertyRow(table, "ID", Format.formatString(identityZone.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(identityZone.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, identityZone.lastmodified);
    this.addPropertyRow(table, "Subdomain", Format.formatString(identityZone.subdomain));
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
