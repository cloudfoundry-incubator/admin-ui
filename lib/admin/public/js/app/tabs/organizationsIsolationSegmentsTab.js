
function OrganizationsIsolationSegmentsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ORGANIZATIONS_ISOLATION_SEGMENTS, Constants.URL__ORGANIZATIONS_ISOLATION_SEGMENTS_VIEW_MODEL);
}

OrganizationsIsolationSegmentsTab.prototype = new Tab();

OrganizationsIsolationSegmentsTab.prototype.constructor = OrganizationsIsolationSegmentsTab;

OrganizationsIsolationSegmentsTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var name = item[1] + "/" + item[3];

                                          return this.formatCheckbox(this.id, name, value);
                                      },
                                      this)
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatOrganizationName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatIsolationSegmentName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               }
           ];
};

OrganizationsIsolationSegmentsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected organization isolation segments?",
                                                         "Delete",
                                                         "Deleting Organization Isolation Segments",
                                                         Constants.URL__ORGANIZATIONS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

OrganizationsIsolationSegmentsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

OrganizationsIsolationSegmentsTab.prototype.showDetails = function(table, objects, row)
{
    var organization     = objects.organization;
    var isolationSegment = objects.isolation_segment;

    var organizationLink = this.createFilterLink(Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    var details = document.createElement("div");
    $(details).append(organizationLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "Organization", details, true);

    this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    this.addFilterRow(table, "Isolation Segment", Format.formatStringCleansed(isolationSegment.name), isolationSegment.guid, AdminUI.showIsolationSegments);
    this.addPropertyRow(table, "Isolation Segment GUID", Format.formatString(isolationSegment.guid));
};
