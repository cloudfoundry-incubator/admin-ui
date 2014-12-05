
function QuotasTab(id)
{
    Tab.call(this, id, Constants.URL__QUOTAS_VIEW_MODEL);
}

QuotasTab.prototype = new Tab();

QuotasTab.prototype.constructor = QuotasTab;

QuotasTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

QuotasTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatQuotaName
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
                   "sTitle":  "Instance Memory Limit",
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
                   "sTitle":  "Organizations",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
};

QuotasTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

QuotasTab.prototype.showDetails = function(table, quota, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(quota.name), quota, true);
    this.addPropertyRow(table, "GUID", Format.formatString(quota.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(quota.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, quota.updated_at);
    this.addPropertyRow(table, "Total Services", Format.formatNumber(quota.total_services));
    this.addPropertyRow(table, "Total Routes", Format.formatNumber(quota.total_routes));
    this.addPropertyRow(table, "Memory Limit", Format.formatNumber(quota.memory_limit));
    this.addRowIfValue(this.addPropertyRow, table, "Instance Memory Limit", Format.formatNumber, quota.instance_memory_limit);
    this.addPropertyRow(table, "Non-Basic Services Allowed", Format.formatString(quota.non_basic_services_allowed));

    if (row[9] != null)
    {
        this.addFilterRow(table, "Organizations", Format.formatNumber(row[9]), quota.name, AdminUI.showOrganizations);
    }
};
