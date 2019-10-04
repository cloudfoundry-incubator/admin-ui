var Table =
{
    ignoreScroll: false,

    tablePageNumbers:        {},
    tableScrollPositions:    {},
    tableSelectedRowVisible: {},

    addClearFilterButton: function(containerID, table)
    {
        var button = document.createElement("img");

        $(button).attr("src", "images/clear.png");

        $(button).css("cursor",         "pointer");
        $(button).css("vertical-align", "middle");
        $(button).css("margin-left",    "5px");

        $(button).click(function() { table.api().search("").draw(); });

        var filter = $("#" + containerID).find(".dataTables_filter");

        $(filter[0]).append(button);
    },

    createTable: function(tableID, columns, initialSort, clickHandler, tableActions, filename, serverSideURL, afterServerDataCallback)
    {
        var tableConfig = this.getSelectableTableConfiguration(tableID, columns, initialSort, clickHandler, tableActions, filename, serverSideURL, afterServerDataCallback);

        var table = $("#" + tableID + "Table").dataTable(tableConfig);
        var api   = table.api();

        this.wrapRawButtons(api, tableID);

        // Use plugin to cause second delay when entering in search field
        table.fnSetFilteringDelay(1000);

        var containerID = tableID + "TableContainer";

        this.addClearFilterButton(containerID, table);

        $($("#" + tableID + "Table")[0].parentNode).scroll(Table.saveTableScrollPosition);

        api.on("page", Table.saveTablePageNumber);

        if (clickHandler)
        {
            api.on("select", clickHandler);
            api.on("deselect", clickHandler);
        }

        return table;
    },

    getSelectableTableConfiguration: function(tableID, columns, initialSort, clickHandler, tableActions, filename, serverSideURL, afterServerDataCallback)
    {
        var config = {
                         autoWidth:      false,
                         buttons:        [],
                         columns:        columns,
                         dom:            "lfBtipr",
                         lengthMenu:     [5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000],
                         order:          initialSort,
                         pageLength:     AdminUI.settings.table_page_size,
                         pagingType:     "full_numbers",
                         scrollCollapse: true,
                         scrollY:        AdminUI.settings.table_height,
                         select:         false
                     };

        if (serverSideURL)
        {
            config.deferLoading = 0;
            config.processing   = true;
            config.serverSide   = true;
            config.ajax = function(data, callback, settings)
            {
                AdminUI.hideErrorPage();

                // TODO - Drop unused query parameters to minimize query string
                delete data.columns;

                var deferred = $.ajax({
                                          dataType: "json",
                                          type:     "GET",
                                          url:      serverSideURL,
                                          async:    false, // This needs to be sync or we cannot know when to reset selection after draw.
                                          data:     data
                                      });

                deferred.done(function(result, status)
                              {
                                  if (!result.items.connected)
                                  {
                                      var errorText = "This page requires data from services that are currently unavailable";

                                      // Support additional error information if provided from the server
                                      if (result.items.error)
                                      {
                                          errorText +=". Error: " + result.items.error;
                                      }

                                      AdminUI.showErrorPage(errorText);
                                  }

                                  // Have to modify the items to get them to work since we want to return
                                  // connected and items initially as children of outermost items for use here, but jquery
                                  // just wants the leaf items array and with the name data.
                                  result.data = result.items.items;
                                  callback(result);
                              });

                deferred.fail(function(xhr, status, error)
                              {
                                  if (xhr.status == 303)
                                  {
                                      window.location.href = Constants.URL__LOGIN;
                                  }
                                  else
                                  {
                                      AdminUI.showErrorPage("This page requires data from services that are currently unavailable");

                                      // Have to make the callback or the table processing message won't terminate
                                      callback({
                                                   draw:            data.draw, 
                                                   recordsTotal:    0, 
                                                   recordsFiltered: 0, 
                                                   data:            []
                                      });
                                  }
                              });

                deferred.always(function(xhr, status, error)
                                {
                                    // The Stats tab needs to know when new server data has been fetched so it can redraw its graph
                                    if (afterServerDataCallback != null)
                                    {
                                        afterServerDataCallback();
                                    }

                                    // Retrieval from the back end should clear any header check box
                                    $("#" + tableID + "TableContainer").find(".headerCheckBox").each(function(index, value)
                                                                                                     {
                                                                                                         if (value.checked == true)
                                                                                                         {
                                                                                                             value.checked = false;
                                                                                                         }
                                                                                                     });
                                });
            };
        }

        if (clickHandler != null)
        {
            config.select =
            {
                style: "single"
            };
        }

        var buttonIDPrefix = "Buttons_" + tableID + "Table_";
        var buttonIndex = 0;

        if ((tableActions != null) && (AdminUI.settings.admin))
        {
            for (var actionIndex = 0; actionIndex < tableActions.length; actionIndex++)
            {
                var tableAction = tableActions[actionIndex];
                config.buttons.push({
                                        text:   tableAction.text,
                                        action: tableAction.click,
                                        attr:   { id: buttonIDPrefix + actionIndex } // Assign ID to button so we can test the button
                                    });
            }
            
            buttonIndex = tableActions.length;
        }

        // Determine columns which are not of type "html". We don't wish to export "html" columns
        var exportableColumns = [];

        for (var columnIndex = 0; columnIndex < columns.length; columnIndex++)
        {
            var column = columns[columnIndex];

            if (column.type != "html")
            {
                exportableColumns.push(columnIndex);
            }
        }

        var exportOptions = { stripHtml: false, columns: exportableColumns };

        var title = filename.split('_').map(function(val)
                                            { 
                                                return val.charAt(0).toUpperCase() + val.substr(1).toLowerCase();
                                            }).join(' ');

        config.buttons.push({
                                extend:        "copy",
                                title:         title,
                                exportOptions: exportOptions,
                                attr:          { id: buttonIDPrefix + buttonIndex } // Assign ID to button so we can test the button
                            });

        config.buttons.push({
                                extend:        "print",
                                title:         title,
                                exportOptions: exportOptions,
                                attr:          { id: buttonIDPrefix + (buttonIndex + 1) } // Assign ID to button so we can test the button
                            }); 

        config.buttons.push({
                                extend:    "collection",
                                text:      "Save",
                                attr:      { id: buttonIDPrefix + (buttonIndex + 2) }, // Assign ID's to button so we can test the buttons
                                autoClose: true,
                                buttons:
                                [
                                    {
                                        extend:        "csv",
                                        filename:      filename,
                                        title:         title,
                                        exportOptions: exportOptions,
                                        attr:          { id: buttonIDPrefix + (buttonIndex + 3) } // Assign ID to button so we can test the button
                                    }, 
                                    {
                                        extend:        "excel",
                                        filename:      filename,
                                        title:         title,
                                        exportOptions: exportOptions,
                                        attr:          { id: buttonIDPrefix + (buttonIndex + 4) } // Assign ID to button so we can test the button
                                    }, 
                                    {
                                        extend:        "pdf",
                                        filename:      filename,
                                        title:         title,
                                        exportOptions: exportOptions,
                                        orientation:   "landscape",
                                        attr:          { id: buttonIDPrefix + (buttonIndex + 5) } } // Assign ID to button so we can test the button
                                ]
                            });

        if (serverSideURL)
        {
            config.buttons.push({
                                    text:   "Download",
                                    action: function() { Table.download(columns, serverSideURL); },
                                    attr:   { id: buttonIDPrefix + (buttonIndex + 6) } // Assign ID to button so we can test the button
                                });
        }

        return config;
    },

    /**
     * Need to wrap the actions of the buttons where we want Format.raw to be true.
     * This consists of the built-in buttons.
     */
    wrapRawButtons: function(api, tableID)
    {
        var buttons = api.buttons();

        for (var buttonIndex = 0; buttonIndex < buttons.length; buttonIndex++)
        {
            var button = buttons[buttonIndex];
            var node = button.node;

            // Get button object so we can access its text and action
            button = api.button(node);

            var text = button.text();
            if ((text == "Copy") || (text == "CSV") || (text == "Excel") || (text == "PDF"))
            {
                var action = button.action();

                // Need closure so the values are not the last values from the buttons loop
                (function(originalButton, originalAction)
                {
                    var wrappingAction = function( e, dt, button, config )
                                         {
                                             Format.raw = true;

                                             try
                                             {
                                                 originalAction.call(originalButton, e, dt, button, config);
                                             }
                                             finally
                                             {
                                                 Format.raw = false;
                                             }
                                         }

                    originalButton.action(wrappingAction);
                })(button, action)
            }
        };
    },

    download: function(columns, serverSideURL)
    {
        AdminUI.showModalDialogProgress("Download");

        try
        {
            var headings = [];
            for (var columnIndex = 0; columnIndex < columns.length; columnIndex++)
            {
                var column = columns[columnIndex];
                var title  = column.title;

                // Replace a column heading where the heading is html
                if (column.type == "html")
                {
                    title = "";
                }

                headings.push(title);
            }

            var input   = document.createElement("input");
            input.type  = "text";
            input.name  = "headings";
            input.value = JSON.stringify(headings);

            var form     = document.createElement("form");
            form.method  = "POST";
            form.action  = serverSideURL;

            form.appendChild(input);

            $("body").append(form);

            try
            {
                form.submit();
            }
            finally
            {
                form.remove();
            }
        }
        finally
        {
            AdminUI.hideModalDialog();
        }
    },

    isSelectedTableRowVisible: function(type)
    {
        var tableName = type + "Table";

        var table = $("#" + tableName).DataTable();
        var selected = table.rows({ selected: true }).nodes();

        var visible = false;

        if (selected.length > 0)
        {
            var row = selected[0];

            var table = $("#" + tableName)[0];

            var scrollBody = table.parentNode;

            var scrollPosition = scrollBody.scrollTop;

            var tableHeight = scrollBody.clientHeight;

            var rowTop    = row.firstChild.offsetTop;
            var rowHeight = row.clientHeight;

            if ((rowTop > scrollPosition) && ((rowTop + rowHeight) < (scrollPosition + tableHeight)))
            {
                visible = true;
            }
        }

        return visible;
    },

    restoreSelectedTableRowVisible: function(type)
    {
        if (Table.tableSelectedRowVisible[type + "Table"])
        {
            Table.scrollSelectedTableRowIntoView(type);
        }
    },

    restoreTablePageNumber: function(type)
    {
        var table = $("#" + type + "Table").DataTable();
        if (table != null)
        {
            var pageNumber = Table.tablePageNumbers[type + "Table"] || 0;

            // The page change triggers a saveTableScrollPosition() which corrupts the scroll position...
            Table.ignoreScroll = true;

            try
            {
                table.page(pageNumber).draw(false);
            }
            finally
            {
                Table.ignoreScroll = false;
            }
        }
    },

    restoreTableScrollPosition: function(type)
    {
        var table = $("#" + type + "Table")[0];
        if (table != null)
        {
            var scrollPosition = Table.tableScrollPositions[type + "Table"];

            table.parentNode.scrollTop = scrollPosition;
        }
    },

    saveSelectedTableRowVisible: function()
    {
        var type = $(".menuItemSelected").attr("id");
        if (type != null)
        {
            Table.tableSelectedRowVisible[type + "Table"] = Table.isSelectedTableRowVisible(type);
        }
    },

    saveTablePageNumber: function(event)
    {
        var tableName = event.currentTarget.id;

        var table = $("#" + tableName).DataTable();

        Table.tablePageNumbers[tableName] = table.page();
    },

    saveTableScrollPosition: function(event)
    {
        if (!Table.ignoreScroll)
        {
            Table.tableScrollPositions[event.target.childNodes[0].id] = event.target.scrollTop;

            Table.saveSelectedTableRowVisible();
        }
    },

    scrollSelectedTableRowIntoView: function(tableType)
    {
        var tableName = tableType + "Table";

        var table = $("#" + tableName).DataTable();
        var selected = table.rows({ selected: true }).nodes();

        if (selected.length > 0)
        {
            var row = selected[0];

            var table = $("#" + tableName)[0];

            var scrollHeight = table.scrollHeight;

            var scrollBody = table.parentNode;

            var scrollPosition = scrollBody.scrollTop;

            var tableHeight = scrollBody.clientHeight;

            var rowTop    = row.firstChild.offsetTop;
            var rowHeight = row.clientHeight;

            var newTop = scrollPosition;

            /*
            if (rowTop < scrollPosition)
            {
                newTop = (rowTop - rowHeight);

            }
            else if ((rowTop + rowHeight) > (scrollPosition + tableHeight))
            {
                newTop = rowTop - tableHeight + (rowHeight * 2);
            }
            */

            if ((rowTop < scrollPosition) || ((rowTop + rowHeight) > (scrollPosition + tableHeight)))
            {
                newTop = rowTop - (tableHeight / 2) + (rowHeight / 2);
            }

            newTop = Math.max(newTop, 0);
            newTop = Math.min(newTop, (scrollHeight - tableHeight));

            if (newTop != scrollPosition)
            {
                scrollBody.scrollTop = newTop;
            }
        }
    },

    setTableScrollPosition: function(type, scrollPosition)
    {
        Table.tableScrollPositions[type + "Table"] = scrollPosition;

        var table = $("#" + type + "Table")[0];
        if (table != null)
        {
            table.parentNode.scrollTop = scrollPosition;
        }
    }
};
