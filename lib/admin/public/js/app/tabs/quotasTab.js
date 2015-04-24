
function QuotasTab(id)
{
    Tab.call(this, id, Constants.URL__QUOTAS_VIEW_MODEL);
}

QuotasTab.prototype = new Tab();

QuotasTab.prototype.constructor = QuotasTab;

QuotasTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

QuotasTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":    "&nbsp;",
                   "sWidth":    "2px",
                   "sClass":    "cellCenterAlign",
                   "bSortable": false,
                   "mRender":   function(value, type, item)
                   {
                       return Tab.prototype.formatCheckbox(item[1], value);
                   }
               },
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
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Organizations",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
};

QuotasTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected quota definitions?",
                                          "Delete",
                                          "Deleting Quota Definitions",
                                          Constants.URL__QUOTA_DEFINITIONS,
                                          "");
                   },
                   this)
               },
           ];
};

QuotasTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
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
    this.addPropertyRow(table, "Non-Basic Services Allowed", Format.formatBoolean(quota.non_basic_services_allowed));

    if (row[10] != null)
    {
        this.addFilterRow(table, "Organizations", Format.formatNumber(row[10]), quota.name, AdminUI.showOrganizations);
    }
};
