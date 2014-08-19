
function DevelopersTab(id)
{
    Tab.call(this, id, Constants.URL__DEVELOPERS_VIEW_MODEL);
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
                   "sWidth": "200px",
                   "mRender": Format.formatStringCleansed
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
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               }
           ];
};

DevelopersTab.prototype.clickHandler = function()
{
    this.itemClicked(6, true);
};

DevelopersTab.prototype.showDetails = function(table, objects, row)
{
    user = objects.user_uaa;
    
    var email = "mailto:" + Format.formatString(row[0]);
    var emailLink = document.createElement("a");
    $(emailLink).attr("target", "_blank");
    $(emailLink).attr("href", email);
    $(emailLink).addClass("tableLink");
    $(emailLink).html(email);

    var details = document.createElement("div");
    $(details).append(emailLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "Email", details, true);

    this.addPropertyRow(table, "Created",     Format.formatDateString(user.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, user.lastmodified);
    this.addPropertyRow(table, "Authorities", Format.formatString(objects.authorities));

    if (row[3] != "")
    {
        var spaceLink = document.createElement("a");
        $(spaceLink).attr("href", "");
        $(spaceLink).addClass("tableLink");
        $(spaceLink).html(Format.formatStringCleansed(row[1]));
        $(spaceLink).click(function()
        {
            // Select based on org/space target since space name is not unique.
            AdminUI.showSpaces(Format.formatString(row[3]));

            return false;
        });

        this.addRow(table, "Space", spaceLink);
    }

    if (row[2] != "")
    {
        var organizationLink = document.createElement("a");
        $(organizationLink).attr("href", "");
        $(organizationLink).addClass("tableLink");
        $(organizationLink).html(Format.formatStringCleansed(row[2]));
        $(organizationLink).click(function()
        {
            AdminUI.showOrganizations(Format.formatString(row[2]));

            return false;
        });

        this.addRow(table, "Organization", organizationLink);
    }
};
