
function QuotasTab(id)
{
    Tab.call(this, id, Constants.FILENAME__QUOTAS, Constants.URL__QUOTAS_VIEW_MODEL);
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
                   title:     "Total Private Domains",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
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
                   title:     "Organizations",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               }
           ];
};

QuotasTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Rename",
                   click: $.proxy(function()
                                  {
                                      this.renameSingleChecked(this.id,
                                                               "Rename Quota Definition",
                                                               "Managing Quota Definitions",
                                                               Constants.URL__QUOTA_DEFINITIONS);
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected quota definitions?",
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
    this.addRowIfValue(this.addPropertyRow, table, "Total Service Keys", Format.formatNumber, quota.total_service_keys);
    this.addRowIfValue(this.addPropertyRow, table, "Total Routes", Format.formatNumber, quota.total_routes);
    this.addRowIfValue(this.addPropertyRow, table, "Total Reserved Route Ports", Format.formatNumber, quota.total_reserved_route_ports);
    this.addRowIfValue(this.addPropertyRow, table, "Application Instance Limit", Format.formatNumber, quota.app_instance_limit);
    this.addRowIfValue(this.addPropertyRow, table, "Application Task Limit", Format.formatNumber, quota.app_task_limit);
    this.addPropertyRow(table, "Memory Limit", Format.formatNumber(quota.memory_limit));
    this.addRowIfValue(this.addPropertyRow, table, "Instance Memory Limit", Format.formatNumber, quota.instance_memory_limit);
    this.addPropertyRow(table, "Non-Basic Services Allowed", Format.formatBoolean(quota.non_basic_services_allowed));
    this.addFilterRowIfValue(table, "Organizations", Format.formatNumber, row[15], quota.name, AdminUI.showOrganizations);
};
