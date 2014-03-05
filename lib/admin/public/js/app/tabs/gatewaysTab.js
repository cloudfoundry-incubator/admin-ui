
function GatewaysTab(id)
{
    this.url = Constants.URL__GATEWAYS;

    Tab.call(this, id);
}

GatewaysTab.prototype = new Tab();

GatewaysTab.prototype.constructor = GatewaysTab;

GatewaysTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.nodesTable = Table.createTable("GatewaysNodes", this.getNodesColumns(), [[1, "asc"]], null, null);
}

GatewaysTab.prototype.getInitialSort = function()
{
    return [[7, "asc"]];
}

GatewaysTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "100px"
               },
               {
                   "sTitle":  "Index",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "180px",
                   "mRender": Format.formatDateString
               },
               {
                   "sTitle":  "Description",
                   "sWidth":  "200px"
               },
               {
                   "sTitle":  "CPU",
                   "sWidth":  "50px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Memory",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Nodes",
                   "sWidth":  "60px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Available<br/>Capacity",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatAvailableCapacity
               }
           ];
}

GatewaysTab.prototype.getNodesColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "150px"
               },
               {
                   "sTitle":  "Available Capacity",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatAvailableCapacity
               }
           ];
}

GatewaysTab.prototype.refresh = function(reload)
{
    Data.get(this.url, reload).done($.proxy(function(result)
    {
        this.updateData([result], reload);

        this.nodesTable.fnDraw();
    },
    this));
}

GatewaysTab.prototype.updateTableRow = function(row, gateway)
{
    row.push(gateway.name);

    if (gateway.connected)
    {
        row.push(gateway.data.index);

        // For some reason nodes is not an array.
        var numNodes = 0;
        if (gateway.data.nodes != null)
        {
            numNodes = Object.keys(gateway.data.nodes).length;
        }

        row.push(Constants.STATUS__RUNNING);
        row.push(gateway.data.start);
        row.push(gateway.data.config.service.description);
        row.push(gateway.data.cpu);

        // Conditional logic since mem becomes mem_bytes in 157
        if (gateway.data.mem != null) 
        {  
          row.push(gateway.data.mem);
        }
        else if (gateway.data.mem_bytes != null)
        {
          row.push(gateway.data.mem_bytes);
        }
        else
        {
          Utilities.addEmptyElementsToArray(row, 1);
        }

        row.push(numNodes);
        var availableCapacity = this.getGatewayAvailableCapacity(gateway);
        row.push(availableCapacity);

        row.push(gateway);
    }
    else
    {
        Utilities.addEmptyElementsToArray(row, 1);
        row.push(Constants.STATUS__OFFLINE);
        row.push(gateway.data.start != null ? gateway.data.start : "");

        Utilities.addEmptyElementsToArray(row, 6);

        row.push(gateway.uri);
    }
}

GatewaysTab.prototype.getGatewayAvailableCapacity = function(gateway)
{
    var capacity = 0;

    for (var index in gateway.data.nodes)
    {
        var node = gateway.data.nodes[index];

        if ((node.available_capacity != null) && (node.available_capacity > 0))
        {
            capacity += node.available_capacity;
        }
    }

    return capacity;
}

GatewaysTab.prototype.clickHandler = function()
{
    var tableTools = TableTools.fnGetInstance("GatewaysTable");

    var selected = tableTools.fnGetSelectedData();


    this.hideDetails();

    $("#GatewaysNodesDetailsLabel").hide();
    $("#GatewaysNodesTableContainer").hide();

    if ((selected.length > 0) && (selected[0][2] == Constants.STATUS__RUNNING))
    {
        $("#GatewaysDetailsLabel").show();
        $("#GatewaysNodesDetailsLabel").show();
        $("#GatewaysNodesTableContainer").show();


        var containerDiv = $("#GatewaysPropertiesContainer").get(0);

        var table = this.createPropertyTable(containerDiv);

        var gateway = selected[0][9];

        
        this.addPropertyRow(table, "Name",                 gateway.name, true);
        this.addPropertyRow(table, "Index",                Format.formatNumber(gateway.data.index));
        this.addLinkRow(table,     "URI",                  gateway);
        this.addPropertyRow(table, "Supported Versions",   Format.formatString(this.getGatewaySupportedVersions(gateway)));
        this.addPropertyRow(table, "Description",          Format.formatString(gateway.data.config.service.description));
        this.addPropertyRow(table, "Started",              Format.formatDateString(gateway.data.start));
        this.addPropertyRow(table, "Uptime",               Format.formatUptime(gateway.data.uptime));
        this.addPropertyRow(table, "Cores",                Format.formatNumber(gateway.data.num_cores));
        this.addPropertyRow(table, "CPU",                  Format.formatNumber(gateway.data.cpu));
        this.addPropertyRow(table, "Memory",               Format.formatNumber(selected[0][6]));
        this.addPropertyRow(table, "Available Capacity",   Format.formatNumber(selected[0][8]));


        var tableData = [];

        for (var index in gateway.data.nodes)
        {
            var node = gateway.data.nodes[index];

            var nodeRow = [];

            nodeRow.push(node.id);
            nodeRow.push(node.available_capacity);

            tableData.push(nodeRow);
        }

        this.nodesTable.fnClearTable();
        this.nodesTable.fnAddData(tableData);
    }
}

GatewaysTab.prototype.getGatewaySupportedVersions = function(gateway)
{
    var result = "";

    if (gateway != null)
    {
        var versions = gateway.data.config.service.supported_versions;

        if (versions != null)
        {
            var versionAliases = gateway.data.config.service.version_aliases;

            if ((versionAliases != null) && (versionAliases.deprecated != null))
            {
                var index = versions.indexOf(versionAliases.deprecated);

                if (index >= 0)
                {               
                    versions.splice(index, 1);
                }
            }
            
            result = versions.toString();

            result = result.replace(",", ", ");
        }
    }

    return result;   
}

