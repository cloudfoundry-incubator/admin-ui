
function DEAsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__DEAS, Constants.URL__DEAS_VIEW_MODEL);
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
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Index",
                   width:  "300px",
                   render: Format.formatString
               },
               {
                   title:  "Source",
                   width:  "80px",
                   render: Format.formatString
               },
               {
                   title:  "Metrics",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "State",
                   width:  "80px",
                   render: function(value, type, item)
                           {
                               if (item[2] == "doppler")
                               {
                                   return Format.formatDopplerStatus(value, type, item);
                               }
                               else
                               {
                                   return Format.formatStatus(value, type, item);
                               }
                           }
               },
               {
                   title:     "Total",
                   width:     "50px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Running",
                   width:     "50px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Memory",
                   width:     "100px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Disk",
                   width:     "100px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "% CPU",
                   width:     "100px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Memory",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Disk",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Memory",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Disk",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               }
           ];
};

DEAsTab.prototype.clickHandler = function()
{
    this.itemClicked(4, 0);
};

DEAsTab.prototype.showDetails = function(table, dopplerDEA, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[0]), dopplerDEA, true);
    this.addPropertyRow(table, "IP", Format.formatString(dopplerDEA.ip));
    this.addPropertyRow(table, "Index", Format.formatString(dopplerDEA.index));
    this.addPropertyRow(table, "Source", Format.formatString(row[2]));
    this.addPropertyRow(table, "Metrics", Format.formatDateString(row[3]));
    this.addRowIfValue(this.addPropertyRow, table, "Uptime",  Format.formatDopplerUptime, dopplerDEA.uptime);

    if (dopplerDEA.avg_cpu_load != null)
    {
        this.addPropertyRow(table, "CPU Load Avg", Format.formatNumber(dopplerDEA.avg_cpu_load * 100) + "%");
    }

    this.addFilterRowIfValue(table, "Total Instances", Format.formatNumber, row[5], Format.formatString(row[0]), AdminUI.showApplicationInstances);
    this.addRowIfValue(this.addPropertyRow, table, "Running Instances", Format.formatNumber, row[6]);
    this.addRowIfValue(this.addPropertyRow, table, "Instances Memory Used", Format.formatNumber, row[7]);
    this.addRowIfValue(this.addPropertyRow, table, "Instances Disk Used", Format.formatNumber, row[8]);
    this.addRowIfValue(this.addPropertyRow, table, "Instances CPU Used", Format.formatNumber, row[9]);

    if (dopplerDEA.available_memory_ratio != null)
    {
        this.addPropertyRow(table, "Memory Free", Format.formatNumber(dopplerDEA.available_memory_ratio * 100) + "%");
    }

    if (dopplerDEA.available_disk_ratio != null)
    {
        this.addPropertyRow(table, "Disk Free", Format.formatNumber(dopplerDEA.available_disk_ratio * 100) + "%");
    }

    this.addRowIfValue(this.addPropertyRow, table, "Remaining Memory", Format.formatNumber, row[12]);
    this.addRowIfValue(this.addPropertyRow, table, "Remaining Disk", Format.formatNumber, row[13]);
    this.addRowIfValue(this.addPropertyRow, table, "Reservable Stagers", Format.formatNumber, dopplerDEA.reservable_stagers);
};
