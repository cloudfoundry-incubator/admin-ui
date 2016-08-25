
function ApprovalsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__APROVALS, Constants.URL__APPROVALS_VIEW_MODEL);
}

ApprovalsTab.prototype = new Tab();

ApprovalsTab.prototype.constructor = ApprovalsTab;

ApprovalsTab.prototype.getColumns = function()
{
    return [
               {
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatUserString
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Client",
                   "width":  "300px",
                   "render": Format.formatUserString
               },
               {
                   "title":  "Scope",
                   "width":  "200px",
                   "render": Format.formatUserString
               },
               {
                   "title":  "Status",
                   "width":  "180px",
                   "render": Format.formatApprovalStatus
               },
               {
                   "title":  "Updated",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Expires",
                   "width":  "180px",
                   "render": Format.formatString
               }
           ];
};

ApprovalsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1, 2, 3);
};

ApprovalsTab.prototype.showDetails = function(table, objects, row)
{
    var approval = objects.approval;
    var user     = objects.user_uaa;

    var userLink = this.createFilterLink(Format.formatStringCleansed(user.username), approval.user_id, AdminUI.showUsers);
    var details = document.createElement("div");
    $(details).append(userLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "User", details, true);

    this.addPropertyRow(table, "User GUID", Format.formatString(user.id));
    this.addFilterRow(table, "Client", Format.formatStringCleansed(row[2]), row[2], AdminUI.showClients);
    this.addPropertyRow(table, "Scope", Format.formatString(approval.scope));
    this.addPropertyRow(table, "Status", Format.formatString(approval.status));
    this.addPropertyRow(table, "Updated", Format.formatDateString(approval.lastmodifiedat));
    this.addPropertyRow(table, "Expires", Format.formatDateString(approval.expiresat));
};
