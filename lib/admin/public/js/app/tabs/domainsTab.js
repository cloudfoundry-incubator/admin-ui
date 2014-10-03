
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
            "mRender": Format.formatString
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
            "mRender": Format.formatString
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
    this.itemClicked(6, -1);
};

DomainsTab.prototype.showDetails = function(table, objects, row)
{
    domain       = objects.domain
    organization = objects.organization
    
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(domain.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(domain.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(domain.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, domain.updated_at);

    if (organization != null)
    {
        var organizationLink = document.createElement("a");
        $(organizationLink).attr("href", "");
        $(organizationLink).addClass("tableLink");
        $(organizationLink).html(Format.formatStringCleansed(organization.name));
        $(organizationLink).click(function()
        {
            AdminUI.showOrganizations(organization.name);

            return false;
        });

        this.addRow(table, "Organization", organizationLink);
    }

    if (row[5] != null)
    {
        var routesLink = document.createElement("a");
        $(routesLink).attr("href", "");
        $(routesLink).addClass("tableLink");
        $(routesLink).html(Format.formatNumber(row[5]));
        $(routesLink).click(function()
        {
            AdminUI.showRoutes(Format.formatString(domain.name));

            return false;
        });
        this.addRow(table, "Routes", routesLink);
    }
};
