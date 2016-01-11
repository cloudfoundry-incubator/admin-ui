
function CellsTab(id)
{
    Tab.call(this, id, Constants.URL__CELLS_VIEW_MODEL);
}

CellsTab.prototype = new Tab();

CellsTab.prototype.constructor = CellsTab;

CellsTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

CellsTab.prototype.getColumns = function()
{
    return [
               {
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "IP",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":     "Index",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "Metrics Last Gathered",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Status",
                   "width":  "80px",
                   "render": Format.formatDopplerStatus
               },
               {
                   "title":     "Cores",
                   "width":     "50px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Memory",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Memory Heap",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Memory Stack",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Total",
                   "width":     "50px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Remaining",
                   "width":     "50px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Used",
                   "width":     "50px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Capacity",
                   "width":     "50px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Remaining",
                   "width":     "50px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Capacity",
                   "width":     "50px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Remaining",
                   "width":     "50px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               }
           ];
};

CellsTab.prototype.clickHandler = function()
{
    this.itemClicked(4, 0);
};

CellsTab.prototype.showDetails = function(table, cell, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[0]), cell, true);
    this.addPropertyRow(table, "IP", Format.formatString(cell.ip));
    this.addPropertyRow(table, "Index", Format.formatNumber(cell.index));
    this.addPropertyRow(table, "Metrics Last Gathered", Format.formatDateString(row[3]));
    this.addRowIfValue(this.addPropertyRow, table, "Cores", Format.formatNumber, cell.numCPUS);
    this.addRowIfValue(this.addPropertyRow, table, "Memory MB", Format.formatNumber, row[6]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Heap MB", Format.formatNumber, row[7]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Stack MB", Format.formatNumber, row[8]);
    this.addRowIfValue(this.addPropertyRow, table, "Total Containers", Format.formatNumber, row[9]);
    this.addRowIfValue(this.addPropertyRow, table, "Remaining Containers", Format.formatNumber, row[10]);
    this.addRowIfValue(this.addPropertyRow, table, "Used Containers", Format.formatNumber, row[11]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Capacity", Format.formatNumber, row[12]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Remaining", Format.formatNumber, row[13]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Capacity", Format.formatNumber, row[14]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Remaining", Format.formatNumber, row[15]);
    this.addRowIfValue(this.addPropertyRow, table, "Log Sender Total Messages Read", Format.formatNumber, cell.logSenderTotalMessagesRead);
    this.addRowIfValue(this.addPropertyRow, table, "Number Go Routines", Format.formatNumber, cell.numGoRoutines);
    this.addRowIfValue(this.addPropertyRow, table, "Number Mallocs", Format.formatNumber, cell['memoryStats.numMallocs']);
    this.addRowIfValue(this.addPropertyRow, table, "Number Frees", Format.formatNumber, cell['memoryStats.numFrees']);
};
