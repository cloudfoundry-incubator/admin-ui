
function QuotasTab(id)
{
    this.url = Constants.URL__QUOTA_DEFINITIONS;

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
            "mRender": Format.formatDateString
        },
        {
            "sTitle":  "Updated",
            "sWidth":  "180px",
            "mRender": Format.formatDateString
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

QuotasTab.prototype.refresh = function(reload)
{
    var quotasDeferred        = Data.get(Constants.URL__QUOTA_DEFINITIONS, reload);
    var organizationsDeferred = Data.get(Constants.URL__ORGANIZATIONS,     reload);

    $.when(quotasDeferred, organizationsDeferred).done($.proxy(function(quotasResult, organizationsResult)
        {
            this.updateData([quotasResult, organizationsResult]);
        },
        this));
};

QuotasTab.prototype.getTableData = function(results)
{
    var quotas        = results[0].response.items;
    var organizations = results[1].response.items;

    var organizationCounterMap = [];

    for (var organizationIndex in organizations)
    {
        var organization = organizations[organizationIndex];
        if (!organizationCounterMap[organization.quota_definition_guid])
        {
            organizationCounterMap[organization.quota_definition_guid] = 1;
        }
        else
        {
            organizationCounterMap[organization.quota_definition_guid] ++;
        }
    }

    var tableData = [];

    for (var quotaIndex in quotas)
    {
        var quota = quotas[quotaIndex];
        var row = [];

        row.push(quota.name);
        row.push(quota.created_at);
        row.push(quota.updated_at);
        row.push(quota.total_services);
        row.push(quota.total_routes);
        row.push(quota.memory_limit);
        row.push(quota.non_basic_services_allowed);
        row.push(quota.trial_db_allowed);
        row.push(organizationCounterMap[quota.guid] || 0);

        row.push(quota);

        tableData.push(row);
    }

    return tableData;
};

QuotasTab.prototype.clickHandler = function()
{
    var tableTools = TableTools.fnGetInstance("QuotasTable");

    var selected = tableTools.fnGetSelectedData();

    this.hideDetails();

    if (selected.length > 0)
    {
        $("#QuotasDetailsLabel").show();

        var containerDiv = $("#QuotasPropertiesContainer").get(0);

        var table = this.createPropertyTable(containerDiv);

        var row = selected[0];

        var quota = row[9];

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
    }
};

QuotasTab.prototype.showQuota = function(quotaName)
{
    // Several calls in this function trigger a saveTableScrollPosition() which corrupts the scroll position.
    Table.ignoreScroll = true;
    
    // Save and clear the sorting so we can select by index.
    var sorting = this.table.fnSettings().aaSorting;
    this.table.fnSort([]);

    var quotasDeferred        = Data.get(Constants.URL__QUOTA_DEFINITIONS, false);
    var organizationsDeferred = Data.get(Constants.URL__ORGANIZATIONS,     false);

    $.when(quotasDeferred, organizationsDeferred).done($.proxy(function(quotasResult, organizationsResult)
    {
        var tableData = this.getTableData([quotasResult, organizationsResult]);
        this.table.fnClearTable();
        this.table.fnAddData(tableData);
        
        for (var index = 0; index < tableData.length; index++)
        {
            var row = tableData[index];

            if (row[0] == quotaName)
            {           
                // Select the quota.
                Table.selectTableRow(this.table, index);

                // Restore the sorting.
                this.table.fnSort(sorting);

                // Move to the Quotas tab.
                AdminUI.setTabSelected(this.id);

                // Show the Quotas tab contents.
                this.show();

                Table.ignoreScroll = false;

                Table.scrollSelectedTableRowIntoView(this.id);                  

                break;
            }
        }
    },
    this));
};
