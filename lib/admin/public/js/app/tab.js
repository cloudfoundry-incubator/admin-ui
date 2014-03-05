
function Tab(id)
{
    this.id = id;

    this.refreshing = false;

    this.stale = true;

    $(document).on(Constants.EVENT__REFRESH, $.proxy(function(event)
    {
        this.stale = true;
    },
    this));
}

Tab.prototype.initialize = function()
{
    this.table = Table.createTable(this.id, this.getColumns(), this.getInitialSort(), $.proxy(this.clickHandler, this), null);
}

Tab.prototype.refresh = function(reload)
{
    Data.get(this.url, reload).done($.proxy(function(result)
    {
        this.updateData([result], reload);
    },
    this));
}

Tab.prototype.updateData = function(results, reload)
{
    var errorMessage = null;

    for (var resultIndex in results)
    {
        var result = results[resultIndex];

        if (result.error != null)
        {
            errorMessage = result.error;
        }
        else if ((result.response.connected != null) && (!result.response.connected))
        {
            errorMessage = "This page requires data from services that are currently unavailable";
        }

        if (errorMessage != null)
        {
            break;
        }
    }

    if (errorMessage != null)
    {
        AdminUI.restoreCursor();

        $("#" + this.id + "Page").addClass("hiddenPage");

        AdminUI.showErrorPage(errorMessage);
    }
    else
    {
        var table = this.table;

        if (reload || this.stale)
        {
            var tableTools = TableTools.fnGetInstance(this.id + "Table");

            var selected = tableTools.fnGetSelected();

            var tableData = this.getTableData(results);

            Table.ignoreScroll = true;

            table.fnClearTable();

            table.fnAddData(tableData);

            Table.ignoreScroll = false;

            Table.restoreTableScrollPosition(this.id);

            var selectedRow = false;

            if (selected.length > 0)
            {
                try
                {
                    // Wrap the select around this flag so that refreshes
                    // don't cause the details to flash.
                    this.refreshing = true;
                    tableTools.fnSelect(selected[0]);
                    this.refreshing = false;

                    selectedRow = true;
                }
                catch (error)
                {
                    Table.setTableScrollPosition(this.id, 0);
                }
            }

            if (!selectedRow)
            {
                //tableTools.fnSelect($('#' + this.id + 'Table tbody tr')[0]);

                if (this.clickHandler)
                {
                    this.clickHandler();
                }
            }

            this.stale = false;
        }

        this.show();

        Table.restoreTablePageNumber(this.id); 

        Table.restoreSelectedTableRowVisible(this.id);
    }
}

Tab.prototype.getTableData = function(results)
{
    var tableData = [];

    var items = results[0].response.items;

    for (var index in items)
    {
        var item = items[index];

        var row = [];

        this.updateTableRow(row, item);

        tableData.push(row);
    }

    return tableData;
}

Tab.prototype.itemClicked = function(index, ignoreState)
{
    var tableTools = TableTools.fnGetInstance(this.id + "Table");

    var selected = tableTools.fnGetSelectedData();

    this.hideDetails();

    if ((selected.length > 0) && (ignoreState || (selected[0][2] == Constants.STATUS__RUNNING)))
    {
        $("#" + this.id + "DetailsLabel").show();

        var containerDiv = $("#" + this.id + "PropertiesContainer").get(0);

        var table = this.createPropertyTable(containerDiv);

        var item = (index > 0) ? selected[0][index] : null;

        this.showDetails(table, item, selected[0]);
    }
}

Tab.prototype.createPropertyTable = function(containerDiv)
{
    var table = document.createElement("table");
    table.cellSpacing = "0";
    table.cellPadding = "0";

    containerDiv.appendChild(table);

    return table;
}

Tab.prototype.addRow = function(table, key, valueElement, first)
{
    var tr = document.createElement("tr");

    var keyTD = document.createElement("td");
    tr.appendChild(keyTD);

    var valueTD = document.createElement("td");
    tr.appendChild(valueTD);

    keyTD.className = "propertyKeyCell";
    keyTD.innerHTML = key + ":";

    valueTD.className = "propertyValueCell";
    valueTD.appendChild(valueElement);

    if (first)
    {
        $(keyTD).addClass("firstPropertyKeyCell");
        $(valueTD).addClass("firstPropertyValueCell");
    }

    table.appendChild(tr);
}

Tab.prototype.addJSONDetailsLinkRow = function(table, key, value, json, first)
{
    var details = document.createElement("div");
    $(details).append(document.createTextNode(value));
    $(details).append(this.createJSONDetailsLink(json));

    this.addRow(table, key, details, first);
}

Tab.prototype.addLinkRow = function(table, key, value, first)
{
    var link = document.createElement("a");

    $(link).addClass("tableLink");

    $(link).text(value.uri);

    this.addLinkClickAction(link, value.data);

    this.addRow(table, key, link, first);
}

Tab.prototype.addLinkClickAction = function(link, json)
{
    $(link).click(function()
    {
        var page = window.open("", "_blank", "fullscreen=yes,menubar=no,scrollbars=yes,titlebar=no,toolbar=no");

        if (page != null)
        {
            page.document.write("<pre>" + JSON.stringify(json, null, 4) + "</pre>");
            page.document.close();
        }
    });
}

Tab.prototype.addPropertyRow = function(table, key, value, first)
{
    this.addRow(table, key, document.createTextNode(value), first);
}

Tab.prototype.addStateRow = function(table, key, value, first)
{
    var span = document.createElement("span");
    span.appendChild(document.createTextNode(value));

    if (value == Constants.STATUS__OFFLINE)
    {
        span.style.color = "rgb(200, 0, 0)";
    }

    this.addRow(table, key, span, first);
}

Tab.prototype.createJSONDetailsLink = function(json)
{
    var detailsLink = document.createElement("img");
    $(detailsLink).attr("src", "images/details.gif");
    $(detailsLink).css("cursor", "pointer");
    $(detailsLink).css("margin-left", "5px");
    $(detailsLink).css("vertical-align", "middle");
    $(detailsLink).height(14);

    this.addLinkClickAction(detailsLink, json);

    return detailsLink;
}

Tab.prototype.hideDetails = function()
{
    var container = $("#" + this.id + "PropertiesContainer");
    container.children().remove();

    $("#" + this.id + "DetailsLabel").hide();
}

Tab.prototype.show = function()
{
    if ($("#" + this.id).hasClass("menuItemSelected"))
    {
        $(".errorPage").hide();
        $(".loadingPage").hide();

        $("#" + this.id + "Page").removeClass("hiddenPage");

        // The redraw triggers a saveTableScrollPosition() which corrupts the scroll position...
        Table.ignoreScroll = true;

        // This code is necessary because when DataTables are shown
        // their scroll headers are not sized correctly until after
        // a redraw.
        this.table.fnDraw();

        var tableTools = TableTools.fnGetInstance(this.id + "Table");
        if ((tableTools != null) && tableTools.fnResizeRequired())
        {
            tableTools.fnResizeButtons();
        }

        Table.restoreTableScrollPosition(this.id);

        Table.ignoreScroll = false;

        AdminUI.restoreCursor();
    }
}

Tab.prototype.getInstanceMap = function(deas)
{
    var instanceMap = [];

    for (var deaIndex in deas)
    {
        var instanceRegistry = deas[deaIndex].data.instance_registry;

        for (var instanceRegistryIndex in instanceRegistry)
        {
            var instances = instanceRegistry[instanceRegistryIndex];

            for (instanceIndex in instances)
            {
                var instance = instances[instanceIndex];
                
                if (instanceMap[instance.application_id] == null)
                {
                    instanceMap[instance.application_id] = [];
                }

                instanceMap[instance.application_id].push(instance);
            }
        }
    }

    return instanceMap;
}

Tab.prototype.addInstanceMetrics = function(countersMap, application, instanceMap)
{
    countersMap.reserved_memory += application.memory;
    countersMap.reserved_disk   += application.disk_quota;

    var instances = instanceMap[application.guid];

    if (instances != null)
    {
        // We keep a temporary map of the instance indices encountered to determine actual instance count
        // Multiple crashed instances can have the same instance_index
        var instanceIndexMap = [];

        for (var instanceIndex in instances)
        {
            var instance = instances[instanceIndex];

            instanceIndexMap[instance.instance_index] = null;

            if (instance.used_memory_in_bytes != null)
            {
                countersMap.used_memory += instance.used_memory_in_bytes;
            }

            if (instance.used_disk_in_bytes != null)
            { 
                countersMap.used_disk += instance.used_disk_in_bytes;
            }

            if (instance.computed_pcpu != null)
            {
                countersMap.used_cpu += instance.computed_pcpu; 
            }

            var services = instance.services;

            if (services != null)
            {
                var numServices = services.length;

                for (var serviceIndex = 0; serviceIndex < numServices; serviceIndex++)
                {
                    var service = services[serviceIndex];

                    // We need a complex key for the service instance
                    // V1 service gateway instances have provider, label, name
                    // V2 service broker instances have label, name
                    // User-provided service instances have label, name
                    var key = service.provider != null ? service.provider : "NoProviderGiven";
                    key += "." + service.label + "." + service.name;

                    // A service instance can be used across multiple applications and we want to ultimately count each instance only once
                    // We need a set of service keys
                    countersMap.services[key] = null;
                }
            }
        }

        countersMap.instances += Object.keys(instanceIndexMap).length;
    }
}


/**
 * Define the columns for the main table.
 */
Tab.prototype.getColumns = function()
{
    return [];
}

/**
 * Define the initial sort for the main table. 
 */
Tab.prototype.getInitialSort = function()
{
    return [];
}

/**
 * Populate the table row with the given row data. If implementations need 
 * access to the full result data they can override getTableData() instead.
 */
Tab.prototype.updateTableRow = function(row, data)
{

}

/**
 * Called when the user clicks on a row from the main table.  Subclasses can 
 * implement this method directly or let the base class handle the visibility
 * of the details section by calling itemClicked().
 *
 * To use itemClicked(), specify the index of the data object in the row and
 * whether or not to require a running state in order for the details to show.
 * If using itemClicked() the subclass would then need to implement the 
 * showDetails method.
 */
Tab.prototype.clickHandler = function()
{
    // Example implementation for subclasses:
    //this.itemClicked(5, false);
}

/**
 * Override this if using clickHandler to manage the detail section visibility.
 * Add rows to the given details table using the provided data.  Rows can be
 * added to the table by using addPropertyRow(), addLinkRow() etc.
 */
Tab.prototype.showDetails = function(table, data, row)
{
    //this.addPropertyRow(table, "Name", data.name, true);
    //this.addPropertyRow(table, "Description", row[1]);
}

