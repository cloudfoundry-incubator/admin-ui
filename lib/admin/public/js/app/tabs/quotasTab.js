
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
            "sTitle":  "Total Services",
            "sWidth":  "80px",
            "mRender": Format.formatNumber
        },
        {
            "sTitle":  "Total Routes",
            "sWidth":  "80px",
            "mRender": Format.formatNumber
        },
        {
            "sTitle":  "Memory Limit",
            "sWidth":  "80px",
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
            "sTitle":  "Created",
            "sWidth":  "180px",
            "sClass":  "cellLeftAlign",
            "mRender": Format.formatDateNumber
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
        row.push(quota.total_services);
        row.push(quota.total_routes);
        row.push(quota.memory_limit);
        row.push(quota.non_basic_services_allowed);
        row.push(quota.trial_db_allowed);
        row.push(quota.created_at);

        row.push({
            "organization_count": organizationCounterMap[quota.guid] || 0,
            "updated_at": quota.updated_at
        });

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

        var objects = row[6];

        var organization = objects.organization;

        this.addPropertyRow(table, "Name", Format.formatString(row[0]));
        this.addPropertyRow(table, "Total Services", Format.formatNumber(row[1]));
        this.addPropertyRow(table, "Total Routes", Format.formatNumber(row[2]));
        this.addPropertyRow(table, "Memory Limit", Format.formatNumber(row[3]));
        this.addPropertyRow(table, "Non-Basic Services Allowed", Format.formatString(row[4]));
        this.addPropertyRow(table, "Trial-DB Allowed", Format.formatString(row[5]));

        var organizationLink = document.createElement("a");
        $(organizationLink).attr("href", "");
        $(organizationLink).addClass("tableLink");
        $(organizationLink).html(Format.formatNumber(row[7].organization_count));
        $(organizationLink).click(function()
        {
            AdminUI.showOrganizations(Format.formatString(row[0]));
            return false;
        });

        this.addRow(table, "Organizations", organizationLink);

        this.addPropertyRow(table, "Created At", Format.formatDateString(row[6]));

        if (row[7].updated_at)
        {
            this.addPropertyRow(table, "Updated At", Format.formatDateString(row[7].updated_at));
        }
    }
};

QuotasTab.prototype.showQuota = function(filter)
{
    AdminUI.setTabSelected(this.id);

    this.hideDetails();

    var quotasDeferred        = Data.get(Constants.URL__QUOTA_DEFINITIONS, false);
    var organizationsDeferred = Data.get(Constants.URL__ORGANIZATIONS,     false);

    $.when(quotasDeferred, organizationsDeferred).done($.proxy(function(quotasResult, organizationsResult)
        {
            this.updateData([quotasResult, organizationsResult]);

            this.table.fnFilter(filter);

            this.show();
        },
        this));
};
