
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
                   "sTitle":    Tab.prototype.formatCheckboxHeader(this.id),
                   "sWidth":    "2px",
                   "bSortable": false,
                   "mRender":   $.proxy(function(value, type, item)
                   {
                       return this.formatCheckbox(item[1], value);
                   },
                   this),
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
                   "sTitle":  "Total Private Domains",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
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
                   text: "Rename",
                   click: $.proxy(function()
                   {
                       this.renameSingleChecked("Rename Quota Definition",
                                                "Managing Quota Definitions",
                                                Constants.URL__QUOTA_DEFINITIONS);
                   }, 
                   this)
               },
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
               }
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
    this.addRowIfValue(this.addPropertyRow, table, "Total Private Domains", Format.formatNumber, quota.total_private_domains);
    this.addPropertyRow(table, "Total Services", Format.formatNumber(quota.total_services));
    this.addRowIfValue(this.addPropertyRow, table, "Total Routes", Format.formatNumber, quota.total_routes);
    this.addPropertyRow(table, "Memory Limit", Format.formatNumber(quota.memory_limit));
    this.addRowIfValue(this.addPropertyRow, table, "Instance Memory Limit", Format.formatNumber, quota.instance_memory_limit);
    this.addPropertyRow(table, "Non-Basic Services Allowed", Format.formatBoolean(quota.non_basic_services_allowed));

    if (row[11] != null)
    {
        this.addFilterRow(table, "Organizations", Format.formatNumber(row[11]), quota.name, AdminUI.showOrganizations);
    }
};
