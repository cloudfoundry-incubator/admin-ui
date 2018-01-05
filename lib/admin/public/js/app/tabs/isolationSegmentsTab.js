
function IsolationSegmentsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ISOLATION_SEGMENTS, Constants.URL__ISOLATION_SEGMENTS_VIEW_MODEL);
}

IsolationSegmentsTab.prototype = new Tab();

IsolationSegmentsTab.prototype.constructor = IsolationSegmentsTab;

IsolationSegmentsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

IsolationSegmentsTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[1], value);
                                      },
                                      this)
               },
               {
                   title:  "Name",
                   width:  "300px",
                   render: Format.formatIsolationSegmentName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:     "Related Organizations",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Default Organizations",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Spaces",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               }
           ];
};

IsolationSegmentsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Create",
                   click: $.proxy(function()
                                  {
                                      this.createIsolationSegment();
                                  },
                                  this)
               },
               {
                   text:  "Rename",
                   click: $.proxy(function()
                                  {
                                      this.renameSingleChecked(this.id,
                                                               "Rename Isolation Segment",
                                                               "Managing Isolation Segments",
                                                               Constants.URL__ISOLATION_SEGMENTS);
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected isolation segments?",
                                                         "Delete",
                                                         "Deleting Isolation Segments",
                                                         Constants.URL__ISOLATION_SEGMENTS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

IsolationSegmentsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

IsolationSegmentsTab.prototype.showDetails = function(table, isolationSegment, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(isolationSegment.name), isolationSegment, true);
    this.addPropertyRow(table, "GUID", Format.formatString(isolationSegment.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(isolationSegment.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, isolationSegment.updated_at);
    this.addFilterRowIfValue(table, "Related Organizations", Format.formatNumber, row[5], isolationSegment.guid, AdminUI.showOrganizationsIsolationSegments);
    this.addFilterRowIfValue(table, "Default Organizations", Format.formatNumber, row[6], isolationSegment.guid, AdminUI.showOrganizations);
    this.addFilterRowIfValue(table, "Spaces", Format.formatNumber, row[7], isolationSegment.guid, AdminUI.showSpaces);
};

IsolationSegmentsTab.prototype.createIsolationSegment = function()
{
    var dialogContentDiv = $("<div></div>");
    dialogContentDiv.append($("<label>Name: </label>"));
    dialogContentDiv.append($("<input type='text' id='isolationSegmentName'>"));

    AdminUI.showModalDialogAction("Create Isolation Segment",
                                  dialogContentDiv,
                                  "Create",
                                  "isolationSegmentName",
                                  $.proxy(function()
                                          {
                                              var isolationSegmentName = $("#isolationSegmentName").val();
                                              if (!isolationSegmentName)
                                              {
                                                  alert("Please input the name first!");
                                                  return;
                                              }

                                              this.doCreateIsolationSegment(isolationSegmentName);
                                          },
                                          this));
};

IsolationSegmentsTab.prototype.doCreateIsolationSegment = function(isolationSegmentName)
{
    AdminUI.showModalDialogProgress("Managing Isolation Segments");

    var deferred = $.ajax({
                              type:        "POST",
                              url:         Constants.URL__ISOLATION_SEGMENTS,
                              contentType: "application/json; charset=utf-8",
                              dataType:    "json",
                              data:        '{"name":"' + isolationSegmentName + '"}'
                          });

    deferred.done(function(response, status)
                  {
                      AdminUI.showModalDialogSuccess();
                  });

    deferred.fail(function(xhr, status, error)
                  {
                      AdminUI.showModalDialogErrorTable([{
                                                             label: isolationSegmentName,
                                                             xhr:   xhr
                                                         }]);
                  });

    deferred.always(function(xhr, status, error)
                    {
                        AdminUI.refresh();
                    });
};
