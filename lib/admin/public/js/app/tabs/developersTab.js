
function DevelopersTab(id)
{
    Tab.call(this, id);
}

DevelopersTab.prototype = new Tab();

DevelopersTab.prototype.constructor = DevelopersTab;

DevelopersTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

DevelopersTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "Email",
                   "sWidth": "200px"
               },
               {
                   "sTitle": "Space",
                   "sWidth": "100px",
                   "mRender": Format.formatSpaceName
               },
               {
                   "sTitle": "Organization",
                   "sWidth": "100px",
                   "mRender": Format.formatOrganizationName
               },
               {
                   "sTitle": "Target",
                   "sWidth": "200px",
                   "mRender": Format.formatTarget
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "180px",
                   "mRender": Format.formatDateString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "180px",
                   "mRender": Format.formatDateString
               }
           ];
};

DevelopersTab.prototype.refresh = function(reload)
{
    var usersDeferred            = Data.get(Constants.URL__USERS,             reload);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            reload);
    var spacesDevelopersDeferred = Data.get(Constants.URL__SPACES_DEVELOPERS, reload);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     reload);

    $.when(usersDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred).done($.proxy(function(usersResult, spacesResult, spacesDevelopersResult, organizationsResult)
    {
        this.updateData([usersResult, spacesResult, spacesDevelopersResult, organizationsResult], reload);
    },
    this));
};

DevelopersTab.prototype.getTableData = function(results)
{
    var users         = results[0].response.items;
    var spaces        = results[1].response.items;
    var developers    = results[2].response.items;
    var organizations = results[3].response.items;


    var userMap = [];

    for (var userIndex in users)
    {
        var user = users[userIndex];

        userMap[user.id] = user;
    }


    var spaceMap = [];

    for (var spaceIndex in spaces)
    {
        var space = spaces[spaceIndex];

        spaceMap[space.guid] = space;
    }


    var organizationMap = [];
    
    for (var organizationIndex in organizations)
    {
        var organization = organizations[organizationIndex];

        organizationMap[organization.guid] = organization;
    }


    var tableData = [];

    for (var developerIndex in developers)
    {
        var developer = developers[developerIndex];

        var user = userMap[developer.user_guid];

        if (user != null)
        {
            var row = [];

            row.push(user.email);

            var space = spaceMap[developer.space_guid];
            
            if (space != null)
            {
                row.push(space.name);

                var organization = organizationMap[space.organization_guid];

                if (organization != null)
                {
                    row.push(organization.name);
                    row.push(organization.name + "/" + space.name);
                }
                else
                {
                    Utilities.addEmptyElementsToArray(row, 2);
                }
            }
            else
            {
                Utilities.addEmptyElementsToArray(row, 3);
            }

            row.push(user.created);
            if (user.updated != null)
            {
                row.push(user.updated);
            } 
            else
            {
                Utilities.addEmptyElementsToArray(row, 1);
            }
            row.push(user);

            tableData.push(row);
        }
    }

    return tableData;
};

DevelopersTab.prototype.clickHandler = function()
{
    this.itemClicked(6, true);
};

DevelopersTab.prototype.showDetails = function(table, user, row)
{
    var email = "mailto:" + Format.formatString(row[0]);
    var emailLink = document.createElement("a");
    $(emailLink).attr("target", "_blank");
    $(emailLink).attr("href", email);
    $(emailLink).addClass("tableLink");
    $(emailLink).html(email);

    var details = document.createElement("div");
    $(details).append(emailLink);
    $(details).append(this.createJSONDetailsLink(user));

    this.addRow(table, "Email", details, true);

    this.addPropertyRow(table, "Created",      Format.formatDate(user.created));
    Utilities.hitchWhenHavingValue(this,       table,  this.addPropertyRow, "Updated", Format.formatDate, user.updated);
    this.addPropertyRow(table, "Modified",     Format.formatDateString(user.last_modified));
    this.addPropertyRow(table, "Authorities",  Format.formatString(user.authorities));

    if (row[3] != "")
    {
        var spaceLink = document.createElement("a");
        $(spaceLink).attr("href", "");
        $(spaceLink).addClass("tableLink");
        $(spaceLink).html(Format.formatString(row[1]));
        $(spaceLink).click(function()
        {
            // Select based on org/space target since space name is not unique.
            AdminUI.showSpace(Format.formatString(row[3]));

            return false;
        });

        this.addRow(table, "Space", spaceLink);
    }

    if (row[2] != "")
    {
        var organizationLink = document.createElement("a");
        $(organizationLink).attr("href", "");
        $(organizationLink).addClass("tableLink");
        $(organizationLink).html(Format.formatString(row[2]));
        $(organizationLink).click(function()
        {
            AdminUI.showOrganization(Format.formatString(row[2]));

            return false;
        });

        this.addRow(table, "Organization", organizationLink);
    }
};

DevelopersTab.prototype.showDevelopers = function(filter)
{
    AdminUI.setTabSelected(this.id);

    this.hideDetails();

    var usersDeferred            = Data.get(Constants.URL__USERS,             false);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            false);
    var spacesDevelopersDeferred = Data.get(Constants.URL__SPACES_DEVELOPERS, false);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     false);

    $.when(usersDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred).done($.proxy(function(usersResult, spacesResult, spacesDevelopersResult, organizationsResult)
    {
        var tableData = this.getTableData([usersResult, spacesResult, spacesDevelopersResult, organizationsResult]);

        this.table.fnClearTable();
        this.table.fnAddData(tableData);

        this.table.fnFilter(filter);

        this.show();
    },
    this));
};

