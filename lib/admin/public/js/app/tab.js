
function Tab(id, url)
{
    this.id  = id;
    this.url = url;

    this.refreshing = false;
}

Tab.prototype.initialize = function()
{
    this.table = Table.createTable(this.id, this.getColumns(), this.getInitialSort(), $.proxy(this.clickHandler, this), this.getActions(), this.url, null);
};

Tab.prototype.refresh = function()
{
    var selected   = [];
    var tableTools = TableTools.fnGetInstance(this.id + "Table");
    
    selected = tableTools.fnGetSelected();
        
    // If nothing selected, we need to clear the details section, preferably before initial draw
    if ((selected.length == 0) && (this.clickHandler))
    {
        this.clickHandler();
    }

    this.show(false);

    Table.restoreTablePageNumber(this.id);
    
    Table.restoreTableScrollPosition(this.id);
    
    if (selected.length > 0)
    {
        try
        {
            // Wrap the select with this flag so that refreshes
            // don't cause the details to flash.
            this.refreshing = true;
    
            try
            {
                tableTools.fnSelect(selected[0]);
            }
            finally
            {
                this.refreshing = false;
            }
        }
        catch (error)
        {
            if (this.clickHandler)
            {
                this.clickHandler();
            }
            
            Table.setTableScrollPosition(this.id, 0);
        }
    }

    Table.restoreSelectedTableRowVisible(this.id);
};

Tab.prototype.formatCheckbox = function(name, value)
{
    return "<input type='checkbox' name='" + escape(name) + "' value='" + value + "' onclick='Tab.prototype.checkboxClickHandler(event)'></input>";
}

Tab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

Tab.prototype.getChecked = function()
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        AdminUI.showModalDialogError("Please select at least one row!");
        
        return null;
    }

    var results = [];

    for (var checkedIndex = 0; checkedIndex < checkedRows.length; checkedIndex++)
    {
        var checkedRow = checkedRows[checkedIndex];
        
        results.push({
                         name: unescape(checkedRow.name),
                         key:  checkedRow.value
                     });
    }

    return results;
};

Tab.prototype.deleteChecked = function(prompt, progress, baseURL)
{
    var checkedItems = this.getChecked();

    if (!checkedItems || checkedItems.length == 0)
    {
        return;
    }

    AdminUI.showModalDialogConfirmation(prompt,
                                        "Delete",
                                        function()
                                        {
                                            AdminUI.showModalDialogProgress(progress);
        
                                            var processed = 0;
                                            
                                            var errorCheckedItems = [];
                                        
                                            for (var checkedItemsIndex = 0; checkedItemsIndex < checkedItems.length; checkedItemsIndex++)
                                            {
                                                var checkedItem = checkedItems[checkedItemsIndex];
                                                
                                                var deferred = $.ajax({
                                                                          type:        "DELETE",
                                                                          url:         baseURL + "/" + checkedItem.key,
                                                                          // Need name inside the fail method
                                                                          checkedName: checkedItem.name
                                                                      });
                                                
                                                deferred.fail(function(xhr, status, error)
                                                {
                                                    errorCheckedItems.push({
                                                                               label: this.checkedName, 
                                                                               xhr:   xhr
                                                                           });
                                                });
                                                
                                                deferred.always(function(xhr, status, error)
                                                {
                                                    processed++;
                                                    
                                                    if (processed == checkedItems.length)
                                                    {
                                                        if (errorCheckedItems.length > 0)
                                                        {
                                                            AdminUI.showModalDialogErrorTable(errorCheckedItems);
                                                        }
                                                        else
                                                        {
                                                            AdminUI.showModalDialogSuccess();
                                                        }
                                                
                                                        AdminUI.refresh();
                                                    }
                                                });
                                            }
                                        });
};

/**
 * Pass in indices to the selected table row as key arguments.  At least one key index is required
 * The url will be constructed as follows:  <base_url>/key_1_value/key_2_value/.../key_n_value
 */
Tab.prototype.itemClicked = function(stateIndex, key1Index)
{
    var tableTools = TableTools.fnGetInstance(this.id + "Table");

    var selected = tableTools.fnGetSelectedData();

    this.hideDetails();

    if ((selected.length > 0) && ((stateIndex < 0) || (selected[0][stateIndex] == Constants.STATUS__RUNNING)))
    {
        var row = selected[0];
        
        var url = this.url;
        for (var index = 1; index < arguments.length; index++)
        {
            var keyValue = row[arguments[index]];
            if (keyValue != null)
            {
                url += "/" + row[arguments[index]]
            }
        }
        
        var deferred = $.ajax({ 
                                  dataType: "json",
                                  type:     "GET",
                                  url:      url,
                                  async:    false
                              });

        deferred.done($.proxy(function(result, status)
        {
            $("#" + this.id + "DetailsLabel").show();

            var containerDiv = $("#" + this.id + "PropertiesContainer").get(0);

            var table = this.createPropertyTable(containerDiv);

            this.showDetails(table, result, row);
        },
        this));
        
        deferred.fail(function(xhr, status, error)
        {
            if (xhr.status == 303)
            {
                window.location.href = Constants.URL__LOGIN;
            }
            else
            {
                AdminUI.showModalDialogError("Error retrieving details:<br/><br/>" + error);
            }
        });
    }
};

Tab.prototype.createPropertyTable = function(containerDiv)
{
    var table = document.createElement("table");
    table.cellSpacing = "0";
    table.cellPadding = "0";

    containerDiv.appendChild(table);

    return table;
};

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
};

Tab.prototype.addRowIfValue = function(rowFunction, table, label, formatter, value)
{
    // Have to use === or otherwise index of 0 will be considered as not available
    if (arguments.length < 5 || value == null || value === "")
    {
        return;
    }
    var format = formatter(value, arguments[5], arguments[6], arguments[7], arguments[8]);
    return rowFunction.apply(this, [table,  label, format]);
};

Tab.prototype.addJSONDetailsLinkRow = function(table, key, value, json, first)
{
    var details = document.createElement("div");
    $(details).append(document.createTextNode(value));
    $(details).append(this.createJSONDetailsLink(json));

    this.addRow(table, key, details, first);
};

Tab.prototype.createFilterLink = function(value, filter, AdminUIFilterFunction)
{
    var link = document.createElement("a");
    $(link).attr("href", "");
    $(link).addClass("tableLink");
    $(link).html(value);
    $(link).click(function()
    {
        AdminUIFilterFunction.call(null, filter);

        return false;
    });
    
    return link;
};

Tab.prototype.addFilterRow = function(table, label, value, filter, AdminUIFilterFunction)
{
    var link = this.createFilterLink(value, filter, AdminUIFilterFunction);
    
    this.addRow(table, label, link);
};

Tab.prototype.addFormattableTextRow = function(table, key, value, json, first)
{
    var details = document.createElement("div");
    details.innerHTML = value;

    this.addRow(table, key, details, first);
};

Tab.prototype.addLinkRow = function(table, key, value, first)
{
    var link = document.createElement("a");

    $(link).addClass("tableLink");

    $(link).text(value.uri);

    this.addLinkClickAction(link, value.data);

    this.addRow(table, key, link, first);
};

Tab.prototype.addLinkClickAction = function(link, json)
{
    $(link).click(function()
    {
        Utilities.windowOpen(json);
    });
};

Tab.prototype.addPropertyRow = function(table, key, value, first)
{
    this.addRow(table, key, document.createTextNode(value), first);
};

Tab.prototype.addStateRow = function(table, key, value, first)
{
    var span = document.createElement("span");
    span.appendChild(document.createTextNode(value));

    if (value == Constants.STATUS__OFFLINE)
    {
        span.style.color = "rgb(200, 0, 0)";
    }

    this.addRow(table, key, span, first);
};

Tab.prototype.addURIRow = function(table, label, uri)
{
    var link = document.createElement("a");
    $(link).attr("target", "_blank");
    $(link).attr("href", uri);
    $(link).addClass("tableLink");
    $(link).html(uri);

    this.addRow(table, label, link);
};

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
};

Tab.prototype.hideDetails = function()
{
    var container = $("#" + this.id + "PropertiesContainer");
    container.children().remove();

    $("#" + this.id + "DetailsLabel").hide();
};

Tab.prototype.show = function(adjustColumnSizing)
{
    if ($("#" + this.id).hasClass("menuItemSelected"))
    {
        $("#" + this.id + "Page").removeClass("hiddenPage");

        // This code is necessary because when DataTables are shown
        // their scroll headers are not sized correctly
        if (adjustColumnSizing)
        {
            // The fnAdjustColumnSizing triggers a saveTableScrollPosition() which corrupts the scroll position...
            Table.ignoreScroll = true;
            
            try
            {
                this.table.fnAdjustColumnSizing(false);
            }
            finally
            {
                Table.ignoreScroll = false;
            }
        }

        var tableTools = TableTools.fnGetInstance(this.id + "Table");
        if ((tableTools != null) && tableTools.fnResizeRequired())
        {
            tableTools.fnResizeButtons();
        }
    }
};

Tab.prototype.showFiltered = function(filter)
{
    this.hideDetails();

    this.table.fnFilter(filter);

    this.show(true);
};

/**
 * Define the columns for the main table.
 */
Tab.prototype.getColumns = function()
{
    return [];
};

/**
 * Define the initial sort for the main table. 
 */
Tab.prototype.getInitialSort = function()
{
    return [];
};

/**
 * Define the actions for the main table. 
 */
Tab.prototype.getActions = function()
{
    return [];
};

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
};

/**
 * Override this if using clickHandler to manage the detail section visibility.
 * Add rows to the given details table using the provided data.  Rows can be
 * added to the table by using addPropertyRow(), addLinkRow() etc.
 */
Tab.prototype.showDetails = function(table, data, row)
{
    //this.addPropertyRow(table, "Name", data.name, true);
    //this.addPropertyRow(table, "Description", row[1]);
};

