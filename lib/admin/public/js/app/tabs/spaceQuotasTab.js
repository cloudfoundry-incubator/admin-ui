
function SpaceQuotasTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SPACE_QUOTAS, Constants.URL__SPACE_QUOTAS_VIEW_MODEL);
}

SpaceQuotasTab.prototype = new Tab();

SpaceQuotasTab.prototype.constructor = SpaceQuotasTab;

SpaceQuotasTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[1], value);
                                      },
                                      this)
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatQuotaName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:     "Total Services",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Total Service Keys",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Total Routes",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Total Reserved Route Ports",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Application Instance Limit",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Application Task Limit",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Memory Limit",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Instance Memory Limit",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Non-Basic Services Allowed",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:     "Spaces",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatQuotaName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               }
           ];
};

SpaceQuotasTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Rename",
                   click: $.proxy(function()
                                  {
                                      this.renameSingleChecked(this.id,
                                                               "Rename Space Quota Definition",
                                                               "Managing Space Quota Definitions",
                                                               Constants.URL__SPACE_QUOTA_DEFINITIONS);
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected space quota definitions?",
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
    this.addRowIfValue(this.addPropertyRow, table, "Total Service Keys", Format.formatNumber, spaceQuota.total_services);
    this.addPropertyRow(table, "Total Routes", Format.formatNumber(spaceQuota.total_routes));
    this.addRowIfValue(this.addPropertyRow, table, "Total Reserved Route Ports", Format.formatNumber, spaceQuota.total_reserved_route_ports);
    this.addRowIfValue(this.addPropertyRow, table, "Application Instance Limit", Format.formatNumber, spaceQuota.app_instance_limit);
    this.addRowIfValue(this.addPropertyRow, table, "Application Task Limit", Format.formatNumber, spaceQuota.app_task_limit);
    this.addPropertyRow(table, "Memory Limit", Format.formatNumber(spaceQuota.memory_limit));
    this.addPropertyRow(table, "Instance Memory Limit", Format.formatNumber(spaceQuota.instance_memory_limit));
    this.addPropertyRow(table, "Non-Basic Services Allowed", Format.formatBoolean(spaceQuota.non_basic_services_allowed));
    this.addFilterRowIfValue(table, "Spaces", Format.formatNumber, row[14], spaceQuota.name, AdminUI.showSpaces);

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    }
};
