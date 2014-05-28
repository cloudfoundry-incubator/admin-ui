
function DEAsTab(id)
{
    Tab.call(this, id, Constants.URL__DEAS_VIEW_MODEL);
}

DEAsTab.prototype = new Tab();

DEAsTab.prototype.constructor = DEAsTab;

DEAsTab.prototype.getInitialSort = function()
{
    return [[7, "asc"]];
};

DEAsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "Name",
                   "sWidth": "200px",
                   "mRender": Format.formatString
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
                   "mRender": Format.formatString
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
};

DEAsTab.prototype.getActions = function()
{
    return [
               {
                   text: "Create new DEA", 
                   click: AdminUI.createDEAConfirmation
               }
           ];
};

DEAsTab.prototype.clickHandler = function()
{
    this.itemClicked(10, false);
};

DEAsTab.prototype.showDetails = function(table, dea, row)
{
    this.addPropertyRow(table, "Name",  Format.formatString(dea.name), true);
    this.addPropertyRow(table, "Index", Format.formatNumber(dea.data.index));
    this.addLinkRow(table, "URI", dea);
    this.addPropertyRow(table, "Host", Format.formatString(dea.data.host));
    this.addPropertyRow(table, "Started", Format.formatDateString(dea.data.start));
    this.addRowIfValue(this.addPropertyRow, table, "Uptime",  Format.formatUptime, dea.data.uptime);

    var stacks = dea.data.stacks;
    if (stacks != null)
    {
        for (var stackIndex = 0; stackIndex < stacks.length; stackIndex++)
        {
            var stack = stacks[stackIndex];
            this.addPropertyRow(table, "Stack", Format.formatString(stack)); 
        }
    }

    if (row[7] !== "")
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

    this.addPropertyRow(table, "Cores", Format.formatNumber(dea.data.num_cores));
    this.addRowIfValue(this.addPropertyRow, table, "CPU", Format.formatNumber, dea.data.cpu);
    
    if (dea.data.cpu_load_avg != null)
    {
        this.addPropertyRow(table, "CPU Load Avg", Format.formatNumber(dea.data.cpu_load_avg * 100) + "%");
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Memory", Format.formatNumber, row[6]);
    this.addPropertyRow(table, "Memory Free", Format.formatNumber(dea.data.available_memory_ratio * 100) + "%");
    this.addPropertyRow(table, "Disk Free", Format.formatNumber(dea.data.available_disk_ratio * 100) + "%");
};

DEAsTab.prototype.showDEAs = function(filter)
{
    AdminUI.setTabSelected(this.id);

    this.hideDetails();

    this.table.fnFilter(filter);

    this.show();
};
