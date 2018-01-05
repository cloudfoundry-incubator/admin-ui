
function GatewaysTab(id)
{
    Tab.call(this, id, Constants.FILENAME__GATEWAYS, Constants.URL__GATEWAYS_VIEW_MODEL);
}

GatewaysTab.prototype = new Tab();

GatewaysTab.prototype.constructor = GatewaysTab;

GatewaysTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.nodesTable = Table.createTable("GatewaysNodes", this.getNodesColumns(), [[1, "asc"]], null, null, Constants.FILENAME__GATEWAY_NODES, null, null);
};

GatewaysTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

GatewaysTab.prototype.getColumns = function()
{
    return [
               {
                   title:  "Name",
                   width:  "100px",
                   render: Format.formatStringCleansed
               },
               {
                   title:     "Index",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Source",
                   width:  "80px",
                   render: Format.formatString
               },
               {
                   title:  "State",
                   width:  "80px",
                   render: Format.formatStatus
               },
               {
                   title:  "Started",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Description",
                   width:  "200px",
                   render: Format.formatStringCleansed
               },
               {
                   title:     "CPU",
                   width:     "50px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Memory",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Nodes",
                   width:     "60px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Available Capacity",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatAvailableCapacity
               }
           ];
};

GatewaysTab.prototype.getNodesColumns = function()
{
    return [
               {
                   title:  "Name",
                   width:  "150px",
                   render: Format.formatString
               },
               {
                   title:     "Available Capacity",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatAvailableCapacity
               }
           ];
};

GatewaysTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#GatewaysNodesTableContainer").hide();
};

GatewaysTab.prototype.clickHandler = function()
{
    this.itemClicked(3, 0);
};

GatewaysTab.prototype.showDetails = function(table, gateway, row)
{
    var data = gateway.data;

    this.addPropertyRow(table, "Name",                 gateway.name, true);
    this.addPropertyRow(table, "Index",                Format.formatNumber(gateway.index));
    this.addPropertyRow(table, "Source",               Format.formatString(row[2]));
    this.addLinkRow(table,     "URI",                  gateway);
    this.addPropertyRow(table, "Supported Versions",   Format.formatString(this.getGatewaySupportedVersions(data)));
    this.addPropertyRow(table, "Description",          Format.formatString(data.config.service.description));
    this.addPropertyRow(table, "Started",              Format.formatDateString(data.start));
    this.addPropertyRow(table, "Uptime",               Format.formatUptime(data.uptime));
    this.addPropertyRow(table, "Cores",                Format.formatNumber(data.num_cores));
    this.addPropertyRow(table, "CPU",                  Format.formatNumber(data.cpu));
    this.addPropertyRow(table, "Memory",               Format.formatNumber(row[7]));
    this.addPropertyRow(table, "Available Capacity",   Format.formatNumber(row[9]));

    $("#GatewaysNodesTableContainer").show();

    var tableData = [];

    for (var index in data.nodes)
    {
        var node = data.nodes[index];

        var nodeRow = [];

        nodeRow.push(node.id);
        nodeRow.push(node.available_capacity);

        tableData.push(nodeRow);
    }

    this.nodesTable.api().clear().rows.add(tableData).draw();
};

GatewaysTab.prototype.getGatewaySupportedVersions = function(data)
{
    var result = "";

    if (data != null)
    {
        var versions = data.config.service.supported_versions;

        if (versions != null)
        {
            var versionAliases = data.config.service.version_aliases;

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
};
