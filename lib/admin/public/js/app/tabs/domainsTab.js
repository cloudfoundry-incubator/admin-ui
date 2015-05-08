
function DomainsTab(id)
{
    Tab.call(this, id, Constants.URL__DOMAINS_VIEW_MODEL);
}

DomainsTab.prototype = new Tab();

DomainsTab.prototype.constructor = DomainsTab;

DomainsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.domainsOrganizationsTable = Table.createTable("DomainsOrganizations", this.getDomainsOrganizationsColumns(), [[0, "asc"]], null, null, null, null);
};

DomainsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

DomainsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":    "&nbsp;",
                   "sWidth":    "2px",
                   "sClass":    "cellCenterAlign",
                   "bSortable": false,
                   "mRender":   function(value, type, item)
                   {
                       return Tab.prototype.formatCheckbox(item[1], value);
                   }
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatDomainName
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Owning Organization",
                   "sWidth":  "200px",
                   "mRender": Format.formatOrganizationName
               },
               {
                   "sTitle":  "Private Shared Organizations",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Routes",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
};

DomainsTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected domains?",
                                          "Delete",
                                          "Deleting Domains",
                                          Constants.URL__DOMAINS,
                                          "");
                   },
                   this)
               },
               {
                   text: "Delete Recursive",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected domains and their associated routes?",
                                          "Delete Recursive",
                                          "Deleting Domains and Associated Routes",
                                          Constants.URL__DOMAINS,
                                          "?recursive=true");
                   },
                   this)
               }
           ];
};

DomainsTab.prototype.getDomainsOrganizationsColumns = function()
{
    return [
               {
                   "sTitle":  "Organization",
                   "sWidth":  "100px",
                   "mRender": function(name, type, row)
                   {
                       var privateSharedOrganizationName = Format.formatOrganizationName(name, type);
                       
                       if (Format.doFormatting(type))
                       {
                           return "<a class='tableLink' onclick='AdminUI.showOrganizations(\"" + 
                                  row[1] + 
                                  "\")'>" + 
                                  privateSharedOrganizationName +
                                  "</a><img onclick='DomainsTab.prototype.displayPrivateSharedOrganizationDetail(event, \"" + 
                                  row[2] + 
                                  "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
                       }

                       return privateSharedOrganizationName;
                   }
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               }
           ];
};

DomainsTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);
    
    $("#DomainsOrganizationsTableContainer").hide();
};

DomainsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

DomainsTab.prototype.showDetails = function(table, objects, row)
{
    var domain                     = objects.domain;
    var owningOrganization         = objects.owning_organization;
    var privateSharedOrganizations = objects.private_shared_organizations;
    
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(domain.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(domain.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(domain.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, domain.updated_at);

    if (owningOrganization != null)
    {
        this.addFilterRow(table, "Owning Organization", Format.formatStringCleansed(owningOrganization.name), owningOrganization.guid, AdminUI.showOrganizations);
    }

    if (row[7] != null)
    {
        this.addFilterRow(table, "Routes", Format.formatNumber(row[7]), domain.name, AdminUI.showRoutes);
    }
    
    if (privateSharedOrganizations != null && privateSharedOrganizations.length > 0)
    {
        // Have to show the table prior to populating for its sizing to work correctly.
        $("#DomainsOrganizationsTableContainer").show();

        var domainsOrganizationsTableData = [];

        for (var privateSharedOrganizationIndex = 0; privateSharedOrganizationIndex < privateSharedOrganizations.length; privateSharedOrganizationIndex++)
        {
            var privateSharedOrganization = privateSharedOrganizations[privateSharedOrganizationIndex];

            var privateSharedOrganizationRow = [];

            privateSharedOrganizationRow.push(privateSharedOrganization.name);
            privateSharedOrganizationRow.push(privateSharedOrganization.guid);

            // Need both the index and the actual object in the table
            privateSharedOrganizationRow.push(privateSharedOrganizationIndex);
            privateSharedOrganizationRow.push(privateSharedOrganization);

            domainsOrganizationsTableData.push(privateSharedOrganizationRow);
        }

        this.domainsOrganizationsTable.fnClearTable();
        this.domainsOrganizationsTable.fnAddData(domainsOrganizationsTableData);
    }
};

DomainsTab.prototype.displayPrivateSharedOrganizationDetail = function(event, rowIndex)
{
    var row = $("#DomainsOrganizationsTable").dataTable().fnGetData(rowIndex);

    var privateSharedOrganization = row[3];

    Utilities.windowOpen(privateSharedOrganization);

    event.stopPropagation();

    return false;
};
