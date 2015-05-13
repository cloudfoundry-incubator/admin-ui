
function DEAsTab(id)
{
    Tab.call(this, id, Constants.URL__DEAS_VIEW_MODEL);
}

DEAsTab.prototype = new Tab();

DEAsTab.prototype.constructor = DEAsTab;

DEAsTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
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
                   "sTitle":  "Total",
                   "sWidth":  "50px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Running",
                   "sWidth":  "50px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Memory",
                   "sWidth":  "100px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Disk",
                   "sWidth":  "100px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "% CPU",
                   "sWidth":  "100px",
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
    this.itemClicked(2, 0);
};

DEAsTab.prototype.showDetails = function(table, dea, row)
{
    var data = dea.data;
    
    this.addPropertyRow(table, "Name",  Format.formatString(dea.name), true);
    this.addPropertyRow(table, "Index", Format.formatNumber(dea.index));
    this.addLinkRow(table, "URI", dea);
    this.addPropertyRow(table, "Started", Format.formatDateString(data.start));
    this.addRowIfValue(this.addPropertyRow, table, "Uptime",  Format.formatUptime, data.uptime);

    var stacks = data.stacks;
    if (stacks != null)
    {
        for (var stackIndex = 0; stackIndex < stacks.length; stackIndex++)
        {
            var stack = stacks[stackIndex];
            this.addPropertyRow(table, "Stack", Format.formatString(stack)); 
        }
    }

    this.addPropertyRow(table, "Cores", Format.formatNumber(dea.data.num_cores));
    this.addRowIfValue(this.addPropertyRow, table, "CPU", Format.formatNumber, data.cpu);
    
    if (dea.data.cpu_load_avg != null)
    {
        this.addPropertyRow(table, "CPU Load Avg", Format.formatNumber(data.cpu_load_avg * 100) + "%");
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Memory", Format.formatNumber, row[6]);
    
    if (row[7] != null)
    {
        this.addFilterRow(table, "Total Instances", Format.formatNumber(row[7]), Format.formatString(dea.name), AdminUI.showApplicationInstances);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Running Instances", Format.formatNumber, row[8]);
    this.addRowIfValue(this.addPropertyRow, table, "Instances Memory Used", Format.formatNumber, row[9]);
    this.addRowIfValue(this.addPropertyRow, table, "Instances Disk Used", Format.formatNumber, row[10]);
    this.addRowIfValue(this.addPropertyRow, table, "Instances CPU Used", Format.formatNumber, row[11]);
    this.addPropertyRow(table, "Memory Free", Format.formatNumber(data.available_memory_ratio * 100) + "%");
    this.addPropertyRow(table, "Disk Free", Format.formatNumber(data.available_disk_ratio * 100) + "%");
};
