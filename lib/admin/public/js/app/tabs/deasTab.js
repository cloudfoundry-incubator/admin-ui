
function DEAsTab(id)
{
    this.url = Constants.URL__DEAS;

    Tab.call(this, id);
}

DEAsTab.prototype = new Tab();

DEAsTab.prototype.constructor = DEAsTab;

DEAsTab.prototype.initialize = function()
{ 
    this.table = Table.createTable(this.id, this.getColumns(), this.getInitialSort(), $.proxy(this.clickHandler, this), [{text: "Create new DEA", click: AdminUI.createDEAConfirmation}]);
}

DEAsTab.prototype.getInitialSort = function()
{
    return [[7, "asc"]];
}

DEAsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "Name",
                   "sWidth": "200px"
               },
               {
                   "sTitle":  "Index",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Status",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "170px",
                   "mRender": Format.formatDateString
               },
               {
                   "sTitle":  "Stack",
                   "sWidth":  "80px",
                   "mRender": Format.formatStacks
               },
               {
                   "sTitle":  "CPU",
                   "sWidth":  "50px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Memory",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Apps",
                   "sWidth":  "50px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Memory",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Disk",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
}

DEAsTab.prototype.updateTableRow = function(row, dea)
{
    row.push(dea.name);

    if (dea.connected)
    {
        row.push(dea.data.index);
        row.push(Constants.STATUS__RUNNING);
        row.push(dea.data.start);
        row.push(dea.data.stacks);
        row.push(dea.data.cpu);

        // Conditional logic since mem becomes mem_bytes in 157
        if (dea.data.mem != null) 
        {  
          row.push(dea.data.mem);
        }
        else if (dea.data.mem_bytes != null)
        {
          row.push(dea.data.mem_bytes);
        }
        else
        {
          Utilities.addEmptyElementsToArray(row, 1);
        }

        if (dea.data.instance_registry == undefined)
        {
            row.push(0);
        }
        else
        {
            var numApps = Object.keys(dea.data.instance_registry).length;

            row.push(numApps);
        }

        row.push(dea.data.available_memory_ratio * 100); 
        row.push(dea.data.available_disk_ratio * 100);

        row.push(dea);
    }
    else
    {
        Utilities.addEmptyElementsToArray(row, 1);
        row.push(Constants.STATUS__OFFLINE);
        row.push(dea.data.start != null ? dea.data.start : "");

        Utilities.addEmptyElementsToArray(row, 7);

        row.push(dea.uri);
    }
}

DEAsTab.prototype.clickHandler = function()
{
    this.itemClicked(10, false);
}

DEAsTab.prototype.showDetails = function(table, dea, row)
{
    this.addPropertyRow(table, "Name",    Format.formatString(dea.name), true);
    this.addPropertyRow(table, "Index",   Format.formatNumber(dea.data.index));
    this.addLinkRow(table,     "URI",     dea);
    this.addPropertyRow(table, "Host",    Format.formatString(dea.data.host));
    this.addPropertyRow(table, "Started", Format.formatDateString(dea.data.start));
    this.addPropertyRow(table, "Uptime",  Format.formatUptime(dea.data.uptime));

    var stacks = dea.data.stacks;
    if (stacks != null)
    {
        for (var stackIndex = 0; stackIndex < stacks.length; stackIndex++)
        {
            var stack = stacks[stackIndex];
            this.addPropertyRow(table, "Stack", Format.formatString(stack)); 
        }
    }

    if (row[7] != "")
    {
        var appsLink = document.createElement("a");
        $(appsLink).attr("href", "");
        $(appsLink).addClass("tableLink");
        $(appsLink).html(Format.formatNumber(row[7]));
        $(appsLink).click(function()
        {
            AdminUI.showApplications(Format.formatString(dea.name));

            return false;
        });
        this.addRow(table, "Apps", appsLink);
    }

    this.addPropertyRow(table, "Cores",        Format.formatNumber(dea.data.num_cores));
    this.addPropertyRow(table, "CPU",          Format.formatNumber(dea.data.cpu));
    this.addPropertyRow(table, "CPU Load Avg", Format.formatNumber(dea.data.cpu_load_avg * 100) + "%");
    this.addPropertyRow(table, "Memory",       Format.formatNumber(row[6]));
    this.addPropertyRow(table, "Memory Free",  Format.formatNumber(dea.data.available_memory_ratio * 100) + "%");
    this.addPropertyRow(table, "Disk Free",    Format.formatNumber(dea.data.available_disk_ratio * 100) + "%");
}

DEAsTab.prototype.showDEA = function(deaIndex)
{
    // Several calls in this function trigger a saveTableScrollPosition() which corrupts the scroll position.
    Table.ignoreScroll = true;

    // Save and clear the sorting so we can select by index.
    var sorting = this.table.fnSettings().aaSorting;
    this.table.fnSort([]);

    var deferred = Data.get(Constants.URL__DEAS, false);

    deferred.done($.proxy(function(results)
    {
        var tableData = this.getTableData([results]);

        this.table.fnClearTable();
        this.table.fnAddData(tableData);

        // Select the dea.
        Table.selectTableRow(this.table, deaIndex);

        // Restore the sorting.
        this.table.fnSort(sorting);

        // Move to the DEA tab.
        AdminUI.setTabSelected(this.id);

        // Show the DEA tab contents.
        this.show();

        Table.ignoreScroll = false;

        Table.scrollSelectedTableRowIntoView(this.id);  
    },
    this));
}

