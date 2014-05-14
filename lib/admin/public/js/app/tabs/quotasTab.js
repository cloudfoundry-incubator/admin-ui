
function QuotasTab(id)
{
    this.url = Constants.URL__QUOTAS_TAB;
    
    this.serverSide = true;

    Tab.call(this, id);
}

QuotasTab.prototype = new Tab();

QuotasTab.prototype.constructor = QuotasTab;

QuotasTab.prototype.getColumns = function()
{
    return [
        {
            "sTitle":  "Name",
            "sWidth":  "200px"
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
            "sTitle":  "Total Services",
            "sWidth":  "80px",
            "sClass":  "cellRightAlign",
            "mRender": Format.formatNumber
        },
        {
            "sTitle":  "Total Routes",
            "sWidth":  "80px",
            "sClass":  "cellRightAlign",
            "mRender": Format.formatNumber
        },
        {
            "sTitle":  "Memory Limit",
            "sWidth":  "80px",
            "sClass":  "cellRightAlign",
            "mRender": Format.formatNumber
        },
        {
            "sTitle":  "Non-Basic Services Allowed",
            "sWidth":  "160px",
            "mRender": Format.formatString
        },
        {
            "sTitle":  "Trial-DB Allowed",
            "sWidth":  "160px",
            "mRender": Format.formatString
        },
        {
            "sTitle":  "Organizations",
            "sWidth":  "80px",
            "sClass":  "cellRightAlign",
            "mRender": Format.formatNumber
        }
    ];
};

QuotasTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

QuotasTab.prototype.clickHandler = function()
{
    this.itemClicked(9, true);
};

QuotasTab.prototype.showDetails = function(table, quota, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(quota.name), quota, true);
    this.addPropertyRow(table, "Created", Format.formatDateString(quota.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, quota.updated_at);
    this.addPropertyRow(table, "Total Services", Format.formatNumber(quota.total_services));
    this.addPropertyRow(table, "Total Routes", Format.formatNumber(quota.total_routes));
    this.addPropertyRow(table, "Memory Limit", Format.formatNumber(quota.memory_limit));
    this.addPropertyRow(table, "Non-Basic Services Allowed", Format.formatString(quota.non_basic_services_allowed));
    this.addPropertyRow(table, "Trial-DB Allowed", Format.formatString(quota.trial_db_allowed));

    var organizationLink = document.createElement("a");
    $(organizationLink).attr("href", "");
    $(organizationLink).addClass("tableLink");
    $(organizationLink).html(Format.formatNumber(row[8]));
    $(organizationLink).click(function()
    {
        AdminUI.showOrganizations(Format.formatString(quota.name));
        return false;
    });
    this.addRow(table, "Organizations", organizationLink);
};

QuotasTab.prototype.showQuotas = function(filter)
{
    AdminUI.setTabSelected(this.id);

    this.hideDetails();

    this.table.fnFilter(filter);

    this.show();
};
