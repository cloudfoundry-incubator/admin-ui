
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
                   "title":  "Name",
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
                   "title":     "Source",
                   "width":     "80px",
                   "render":    Format.formatString
               },
               {
                   "title":  "State",
                   "width":  "80px",
                   "render": function(value, type, item)
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
                   "title":  "Started",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Metrics Last Gathered",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Stacks",
                   "width":  "80px",
                   "render": Format.formatStacks
               },
               {
                   "title":     "CPU",
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
                   "title":     "Total",
                   "width":     "50px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Running",
                   "width":     "50px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Memory",
                   "width":     "100px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Disk",
                   "width":     "100px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "% CPU",
                   "width":     "100px",
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
                   "title":     "Disk",
                   "width":     "80px",
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
                   "title":     "Disk",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               }
           ];
};

DEAsTab.prototype.clickHandler = function()
{
    this.itemClicked(3, 0);
};

DEAsTab.prototype.showDetails = function(table, objects, row)
{
    var dopplerDEA = objects.doppler_dea;
    var varzDEA    = objects.varz_dea;
    
    if (varzDEA != null)
    {
        var data = varzDEA.data;
        
        this.addPropertyRow(table, "Name",  Format.formatString(varzDEA.name), true);
        this.addPropertyRow(table, "Index", Format.formatNumber(varzDEA.index));
        this.addPropertyRow(table, "Source", Format.formatString(row[2]));
        this.addLinkRow(table, "URI", varzDEA);
        this.addPropertyRow(table, "Started", Format.formatDateString(data.start));
        this.addRowIfValue(this.addPropertyRow, table, "Uptime",  Format.formatUptime, data.uptime);
    
        var stacks = data.stacks;
        if (stacks != null)
        {
            for (var stackIndex = 0; stackIndex < stacks.length; stackIndex++)
            {
                var stack = stacks[stackIndex];
                this.addFilterRow(table, "Stack", Format.formatStringCleansed(stack), stack, AdminUI.showStacks);
            }
        }
    
        this.addPropertyRow(table, "Cores", Format.formatNumber(data.num_cores));
        this.addRowIfValue(this.addPropertyRow, table, "CPU", Format.formatNumber, data.cpu);
        
        if (data.cpu_load_avg != null)
        {
            this.addPropertyRow(table, "CPU Load Avg", Format.formatNumber(data.cpu_load_avg * 100) + "%");
        }
        
        this.addRowIfValue(this.addPropertyRow, table, "Memory", Format.formatNumber, row[8]);
        
        if (row[9] != null)
        {
            this.addFilterRow(table, "Total Instances", Format.formatNumber(row[9]), Format.formatString(varzDEA.name), AdminUI.showApplicationInstances);
        }
    
        this.addRowIfValue(this.addPropertyRow, table, "Running Instances", Format.formatNumber, row[10]);
        this.addRowIfValue(this.addPropertyRow, table, "Instances Memory Used", Format.formatNumber, row[11]);
        this.addRowIfValue(this.addPropertyRow, table, "Instances Disk Used", Format.formatNumber, row[12]);
        this.addRowIfValue(this.addPropertyRow, table, "Instances CPU Used", Format.formatNumber, row[13]);
        
        if (data.available_memory_ratio != null)
        {
            this.addPropertyRow(table, "Memory Free", Format.formatNumber(data.available_memory_ratio * 100) + "%");
        }
        
        if (data.available_disk_ratio != null)
        {
            this.addPropertyRow(table, "Disk Free", Format.formatNumber(data.available_disk_ratio * 100) + "%");
        }
    }
    else if (dopplerDEA != null)
    {
        this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[0]), dopplerDEA, true);
        this.addPropertyRow(table, "IP", Format.formatString(dopplerDEA.ip));
        this.addPropertyRow(table, "Index", Format.formatNumber(dopplerDEA.index));
        this.addPropertyRow(table, "Source", Format.formatString(row[2]));
        this.addPropertyRow(table, "Metrics Last Gathered", Format.formatDateString(row[5]));
    
        if (row[9] != null)
        {
            this.addFilterRow(table, "Total Instances", Format.formatNumber(row[9]), Format.formatString(row[0]), AdminUI.showApplicationInstances);
        }
    
        this.addRowIfValue(this.addPropertyRow, table, "Running Instances", Format.formatNumber, row[10]);
        this.addRowIfValue(this.addPropertyRow, table, "Instances Memory Used", Format.formatNumber, row[11]);
        this.addRowIfValue(this.addPropertyRow, table, "Instances Disk Used", Format.formatNumber, row[12]);
        this.addRowIfValue(this.addPropertyRow, table, "Instances CPU Used", Format.formatNumber, row[13]);
        this.addRowIfValue(this.addPropertyRow, table, "Remaining Memory", Format.formatNumber, row[16]);
        this.addRowIfValue(this.addPropertyRow, table, "Remaining Disk", Format.formatNumber, row[17]);
    }
};
