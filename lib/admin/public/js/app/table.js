
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

        $(button).click(function()
        {
            table.api().search("").draw();
        });

        var filter = $("#" + containerID).find(".dataTables_filter");

        $(filter[0]).append(button);
    },
    
    // Move the action buttons so they immediately follow the filter.  
    // This works in conjunction with making the div.DTTT_container float left.
    moveButtons: function(containerID)
    {
        var buttons = $("#" + containerID).find(".DTTT_container");
        
        var filter = $("#" + containerID).find(".dataTables_filter");
        
        $(filter[0]).after(buttons);
    },

    createTable: function(tableID, columns, initialSort, clickHandler, tableActions, serverSideURL, afterServerDataCallback)
    {
        var tableConfig = this.getSelectableTableConfiguration(tableID, columns, initialSort, clickHandler, tableActions, serverSideURL, afterServerDataCallback);

        var table = $("#" + tableID + "Table").dataTable(tableConfig);
        
        // Use plugin to cause second delay when entering in search field
        table.fnSetFilteringDelay(1000);

        var containerID = tableID + "TableContainer";

        this.addClearFilterButton(containerID, table);
        
        this.moveButtons(containerID);

        $($("#" + tableID + "Table")[0].parentNode).scroll(Table.saveTableScrollPosition);

        table.api().on("page", Table.saveTablePageNumber);

        return table;
    },

    getSelectableTableConfiguration: function(tableID, columns, initialSort, clickHandler, tableActions, serverSideURL, afterServerDataCallback)
    {
        var config = {
                         "autoWidth":      false,
                         "columns":        columns,
                         "dom":            'T<"clear">lfrtip',
                         "lengthMenu":     [5, 10, 25, 50, 100, 250, 500, 1000],
                         "order":          initialSort,
                         "pageLength":     AdminUI.settings.table_page_size,
                         "pagingType":     "full_numbers",
                         "scrollCollapse": true,
                         "scrollY":        AdminUI.settings.table_height,
                         "oTableTools":    {        
                                               "aButtons": [ ],
                                               "sSwfPath": "js/external/jquery/TableTools-2.1.5/media/swf/copy_csv_xls_pdf.swf"
                                           }
                     };
        
        if (serverSideURL)
        {
            config.deferLoading = 0;
            config.processing   = true;
            config.serverSide   = true;
            config.ajax = function(data, callback, settings) 
            {
                AdminUI.hideErrorPage();
                
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
                        callback({draw:data.draw, recordsTotal:0, recordsFiltered:0, data:[]});
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
            config.oTableTools.sRowSelect      = "single";
            config.oTableTools.fnRowSelected   = clickHandler;
            config.oTableTools.fnRowDeselected = clickHandler;
        }
        else
        {
            config.oTableTools.sRowSelect = "none"; 
        }

        if ((tableActions != null) && (AdminUI.settings.admin))
        {
            for (var actionIndex = 0; actionIndex < tableActions.length; actionIndex++)
            {
                var tableAction = tableActions[actionIndex];
                config.oTableTools.aButtons.push({
                                                     "sExtends":    "text",
                                                     "sButtonText": tableAction.text,
                                                     "fnClick":     tableAction.click
                                                 });
            }
        }

        config.oTableTools.aButtons.push({
                                             "sExtends": "copy",
                                             "fnClick":  function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, tableID); }
                                         });
        config.oTableTools.aButtons.push("print");
        config.oTableTools.aButtons.push({
                                             "sExtends":    "collection",
                                             "sButtonText": "Save",
                                             "aButtons":    
                                             [
                                                 {
                                                     "sExtends": "csv",
                                                     "fnClick":  function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, tableID); }
                                                 },
                                                 {
                                                     "sExtends": "xls",
                                                     "fnClick":  function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, tableID); }
                                                 },
                                                 {
                                                     "sExtends": "pdf",
                                                     "fnClick":  function(nButton, oConfig, flash) { Table.rawPDF(nButton, oConfig, flash, tableID); }
                                                 }
                                             ]
                                         });

        if (serverSideURL) 
        {
            config.oTableTools.aButtons.push({
                                                 "sExtends":    "text",
                                                 "sButtonText": "Download",
                                                 "fnClick":     function() { Table.download(columns, serverSideURL); }
            });
        }

        return config;
    },    

    raw: function(nButton, oConfig, flash, tableID)
    {
        var tableTools = TableTools.fnGetInstance(tableID + "Table");
        
        Format.raw = true;

        tableTools.fnSetText(flash, tableTools.fnGetTableData(oConfig));

        Format.raw = false;
    },

    rawPDF: function(nButton, oConfig, flash, tableID)
    {
        var tableTools = TableTools.fnGetInstance(tableID + "Table");
        
        Format.raw = true;

        tableTools.fnSetText(flash, tableTools.fnGetTableData(oConfig));

        tableTools.fnSetText(flash, "title:"                + tableTools.fnGetTitle(oConfig)      + "\n" +
                                    "message:"              + oConfig.sPdfMessage                 + "\n" +
                                    "colWidth:"             + tableTools.fnCalcColRatios(oConfig) + "\n" +
                                    "orientation:"          + oConfig.sPdfOrientation             + "\n" +
                                    "size:"                 + oConfig.sPdfSize                    + "\n" +
                                    "--/TableToolsOpts--\n" + tableTools.fnGetTableData(oConfig));

        Format.raw = false;
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
        
        var tableTools = TableTools.fnGetInstance(tableName);
        
        var selected = tableTools.fnGetSelected();
        
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
        
        var tableTools = TableTools.fnGetInstance(tableName);
        
        var selected = tableTools.fnGetSelected();
        
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
