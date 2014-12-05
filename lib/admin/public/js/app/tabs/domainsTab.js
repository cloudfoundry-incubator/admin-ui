
function DomainsTab(id)
{
    Tab.call(this, id, Constants.URL__DOMAINS_VIEW_MODEL);
}

DomainsTab.prototype = new Tab();

DomainsTab.prototype.constructor = DomainsTab;

DomainsTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

DomainsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatDomainName
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
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
                   "sTitle":  "Owning Organization",
                   "sWidth":  "200px",
                   "mRender": Format.formatOrganizationName
               },
               {
                   "sTitle":  "Routes",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
};

DomainsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

DomainsTab.prototype.showDetails = function(table, objects, row)
{
    var domain       = objects.domain
    var organization = objects.organization
    
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(domain.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(domain.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(domain.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, domain.updated_at);

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    }

    if (row[5] != null)
    {
        this.addFilterRow(table, "Routes", Format.formatNumber(row[5]), domain.name, AdminUI.showRoutes);
    }
};
