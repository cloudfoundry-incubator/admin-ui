
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
            table.fnFilter("");
        });

        var filter = $("#" + containerID).find(".dataTables_filter");

        $(filter[0]).append(button);
    },

    createTable: function(tableID, columns, initialSort, clickHandler, tableActions)
    {
        var tableConfig = this.getSelectableTableConfiguration(tableID, initialSort, clickHandler, tableActions);

        tableConfig["aoColumns"] = columns;

        var table = $("#" + tableID + "Table").dataTable(tableConfig);

        this.addClearFilterButton(tableID + "TableContainer", table);

        $($("#" + tableID + "Table")[0].parentNode).scroll(Table.saveTableScrollPosition);

        $("#" + tableID + "Table").on("page", Table.saveTablePageNumber);

        return table;
    },

    getSelectableTableConfiguration: function(tableID, initialSort, clickHandler, tableAction)
    {
        var config = {
                         "sPaginationType": "full_numbers",
                         "aLengthMenu": [[5, 10, 25, 50, 100, -1], [5, 10, 25, 50, 100, "All"]],
                         "iDisplayLength": 100,
                         "sScrollY": "300px",
                         "bScrollCollapse": true,
                         "sDom": 'T<"clear">lfrtip',
                         "bAutoWidth": false,
                         "aaSorting": initialSort,
                         "oTableTools": {        
                                            "sSwfPath": "js/external/jquery/TableTools-2.1.5/media/swf/copy_csv_xls_pdf.swf",
                                            "aButtons": [ ]
                                        }
                     };

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

        if ((tableAction != null) && (AdminUI.settings.admin))
        {
            config.oTableTools.aButtons.push({
                                                 "sExtends": "text",
                                                 "sButtonText": tableAction.text,
                                                 "fnClick": tableAction.click
                                             });
        }

        config.oTableTools.aButtons.push({
                                             "sExtends": "copy",
                                             "fnClick": function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, tableID); }
                                         });
        config.oTableTools.aButtons.push("print");
        config.oTableTools.aButtons.push({
                                             "sExtends":    "collection",
                                             "sButtonText": "Save",
                                             "aButtons":    [
                                                                {
                                                                    "sExtends": "csv",
                                                                    "fnClick": function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, tableID); }
                                                                },
                                                                {
                                                                    "sExtends": "xls",
                                                                    "fnClick": function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, tableID); }
                                                                },
                                                                {
                                                                    "sExtends": "pdf",
                                                                    "fnClick": function(nButton, oConfig, flash) { Table.rawPDF(nButton, oConfig, flash, tableID); }
                                                                }
                                                            ]
                                         });

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

    getTablePageNumber: function(table)
    {
        var settings = table.fnSettings();

        return settings._iDisplayLength === -1 ? 0 : Math.ceil(settings._iDisplayStart / settings._iDisplayLength);
    },

    isSelectedTableRowVisible: function(type)
    {
        var tableName = type + "Table";

        var table = $("#" + tableName)[0];

        var scrollBody = table.parentNode;

        var scrollPosition = scrollBody.scrollTop;

        var tableHeight = scrollBody.clientHeight;

        var tableTools = TableTools.fnGetInstance(tableName);

        var visible = false;

        var row = tableTools.fnGetSelected()[0];
  
        if (row != null)
        {
            var rowTop    = row.firstChild.offsetTop;
            var rowHeight = row.clientHeight;

            if ((rowTop > scrollPosition) && ((rowTop + rowHeight) < (scrollPosition + tableHeight)))
            {
                visible = true;
            }
        }

        return visible;
    },

    pageTableRowIntoView: function(tableType, row)
    {
        var tableName = tableType + "Table"; 

        var table = $("#" + tableName).dataTable();

        var settings = table.fnSettings();
          
        var rowIndex = -1;
        var numRows = settings.aiDisplay.length;
        for (var index = 0; index < numRows; index++)
        {
            if (settings.aoData[settings.aiDisplay[index]].nTr == row)
            {
                rowIndex = index;
                break;
            }
        }

        var pageSize = settings._iDisplayLength;

        var pageNum = Math.floor(rowIndex / pageSize);

        table.fnPageChange(pageNum);        
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
        var table = $("#" + type + "Table").dataTable();
        if (table != null)
        {
            var pageNumber = Table.tablePageNumbers[type + "Table"] || 0;

            table.fnPageChange(pageNumber);
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

        var table = $("#" + tableName).dataTable();

        var pageNumber = Table.getTablePageNumber(table);

        Table.tablePageNumbers[tableName] = pageNumber;
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

        var table = $("#" + tableName)[0];

        var scrollHeight = table.scrollHeight;

        var scrollBody = table.parentNode;

        var scrollPosition = scrollBody.scrollTop;

        var tableHeight = scrollBody.clientHeight;

        var tableTools = TableTools.fnGetInstance(tableName);

        var row = tableTools.fnGetSelected()[0];

        this.pageTableRowIntoView(tableType, row);

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
    },

    /**
     * Takes into consideration table paging.  The rowIndex passed in is the 
     * index of the data from the original table data array.
     */
    selectTableRow: function(table, rowIndex)
    {   
        var pageSize = table.fnSettings()._iDisplayLength;

        var pageNum = Math.floor(rowIndex / pageSize);

        var indexInPage = rowIndex % pageSize;

        table.fnPageChange(pageNum);

        var tableTools = TableTools.fnGetInstance(table.selector.substring(1));

        tableTools.fnSelect($(table.selector + " tbody tr")[indexInPage]);
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
}

