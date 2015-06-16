
function SpaceQuotasTab(id)
{
    Tab.call(this, id, Constants.URL__SPACE_QUOTAS_VIEW_MODEL);
}

SpaceQuotasTab.prototype = new Tab();

SpaceQuotasTab.prototype.constructor = SpaceQuotasTab;

SpaceQuotasTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

SpaceQuotasTab.prototype.getColumns = function()
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
                   "sTitle":  "Spaces",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
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
               }
           ];
};

SpaceQuotasTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected space quota definitions?",
                                          "Delete",
                                          "Deleting Space Quota Definitions",
                                          Constants.URL__SPACE_QUOTA_DEFINITIONS,
                                          "");
                   },
                   this)
               }
           ];
};

SpaceQuotasTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

SpaceQuotasTab.prototype.showDetails = function(table, objects, row)
{
    var spaceQuota   = objects.space_quota_definition;
    var organization = objects.organization;
    
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(spaceQuota.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(spaceQuota.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(spaceQuota.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, spaceQuota.updated_at);
    this.addPropertyRow(table, "Total Services", Format.formatNumber(spaceQuota.total_services));
    this.addPropertyRow(table, "Total Routes", Format.formatNumber(spaceQuota.total_routes));
    this.addPropertyRow(table, "Memory Limit", Format.formatNumber(spaceQuota.memory_limit));
    this.addPropertyRow(table, "Instance Memory Limit", Format.formatNumber(spaceQuota.instance_memory_limit));
    this.addPropertyRow(table, "Non-Basic Services Allowed", Format.formatBoolean(spaceQuota.non_basic_services_allowed));

    if (row[10] != null)
    {
        this.addFilterRow(table, "Spaces", Format.formatNumber(row[10]), spaceQuota.name, AdminUI.showSpaces);
    }
    
    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    }
};
