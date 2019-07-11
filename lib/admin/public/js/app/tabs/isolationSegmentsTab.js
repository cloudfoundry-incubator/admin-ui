
function IsolationSegmentsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ISOLATION_SEGMENTS, Constants.URL__ISOLATION_SEGMENTS_VIEW_MODEL);
}

IsolationSegmentsTab.prototype = new Tab();

IsolationSegmentsTab.prototype.constructor = IsolationSegmentsTab;

IsolationSegmentsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.isolationSegmentsLabelsTable = Table.createTable("IsolationSegmentsLabels", this.getIsolationSegmentsLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getIsolationSegmentsLabelsActions(), Constants.FILENAME__ISOLATION_SEGMENT_LABELS, null, null);

    this.isolationSegmentsAnnotationsTable = Table.createTable("IsolationSegmentsAnnotations", this.getIsolationSegmentsAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getIsolationSegmentsAnnotationsActions(), Constants.FILENAME__ISOLATION_SEGMENT_ANNOTATIONS, null, null);
};

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

IsolationSegmentsTab.prototype.getIsolationSegmentsLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("IsolationSegmentsLabels"),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var text = item[2];
                                          if (item[1] != null)
                                          {
                                              text = item[1] + "/" + item[2];
                                          }

                                          return this.formatCheckbox("IsolationSegmentsLabels", text, value);
                                      },
                                      this)
               },
               {
                   title:  "Prefix",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "Key",
                   width:  "200px",
                   render: Format.formatKey
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
                   title:  "Value",
                   width:  "400px",
                   render: Format.formatValue
               }
           ];
};

IsolationSegmentsTab.prototype.getIsolationSegmentsLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("IsolationSegmentsLabels",
                                                         "Are you sure you want to delete the isolation segment's selected labels?",
                                                         "Delete",
                                                         "Deleting IsolationSegment Label",
                                                         Constants.URL__ISOLATION_SEGMENTS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

IsolationSegmentsTab.prototype.getIsolationSegmentsAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("IsolationSegmentsAnnotations"),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var text = item[2];
                                          if (item[1] != null)
                                          {
                                              text = item[1] + "/" + item[2];
                                          }

                                          return this.formatCheckbox("IsolationSegmentsAnnotations", text, value);
                                      },
                                      this)
               },
               {
                   title:  "Prefix",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "Key",
                   width:  "200px",
                   render: Format.formatKey
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
                   title:  "Value",
                   width:  "400px",
                   render: Format.formatValue
               }
           ];
};

IsolationSegmentsTab.prototype.getIsolationSegmentsAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("IsolationSegmentsAnnotations",
                                                         "Are you sure you want to delete the isolation segment's selected annotations?",
                                                         "Delete",
                                                         "Deleting IsolationSegment Annotation",
                                                         Constants.URL__ISOLATION_SEGMENTS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

IsolationSegmentsTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#IsolationSegmentsLabelsTableContainer").hide();
    $("#IsolationSegmentsAnnotationsTableContainer").hide();
};

IsolationSegmentsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

IsolationSegmentsTab.prototype.showDetails = function(table, objects, row)
{
    var annotations      = objects.annotations;
    var isolationSegment = objects.isolation_segment;
    var labels           = objects.labels;

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(isolationSegment.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(isolationSegment.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(isolationSegment.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, isolationSegment.updated_at);
    this.addFilterRowIfValue(table, "Related Organizations", Format.formatNumber, row[5], isolationSegment.guid, AdminUI.showOrganizationsIsolationSegments);
    this.addFilterRowIfValue(table, "Default Organizations", Format.formatNumber, row[6], isolationSegment.guid, AdminUI.showOrganizations);
    this.addFilterRowIfValue(table, "Spaces", Format.formatNumber, row[7], isolationSegment.guid, AdminUI.showSpaces);
    
    if ((labels != null) && (labels.length > 0))
    {
        var labelsTableData = [];

        for (var labelIndex = 0; labelIndex < labels.length; labelIndex++)
        {
            var wrapper = labels[labelIndex];
            var label   = wrapper.label;

            var path = label.resource_guid + "/metadata/labels/" + encodeURIComponent(label.key_name);
            if (label.key_prefix != null)
            {
                path += "?prefix=" + encodeURIComponent(label.key_prefix);
            }

            var labelRow = [];

            labelRow.push(path);
            labelRow.push(label.key_prefix);
            labelRow.push(label.key_name);
            labelRow.push(label.guid);
            labelRow.push(wrapper.created_at_rfc3339);
            labelRow.push(wrapper.updated_at_rfc3339);
            labelRow.push(label.value);

            labelsTableData.push(labelRow);
        }

        // Have to show the table prior to populating for its sizing to work correctly.
        $("#IsolationSegmentsLabelsTableContainer").show();

        this.isolationSegmentsLabelsTable.api().clear().rows.add(labelsTableData).draw();
    }

    if ((annotations != null) && (annotations.length > 0))
    {
        var annotationsTableData = [];

        for (var annotationIndex = 0; annotationIndex < annotations.length; annotationIndex++)
        {
            var wrapper    = annotations[annotationIndex];
            var annotation = wrapper.annotation;

            var path = annotation.resource_guid + "/metadata/annotations/" + encodeURIComponent(annotation.key);
            if (annotation.key_prefix != null)
            {
                path += "?prefix=" + encodeURIComponent(annotation.key_prefix);
            }

            var annotationRow = [];

            annotationRow.push(path);
            annotationRow.push(annotation.key_prefix);
            annotationRow.push(annotation.key);
            annotationRow.push(annotation.guid);
            annotationRow.push(wrapper.created_at_rfc3339);
            annotationRow.push(wrapper.updated_at_rfc3339);
            annotationRow.push(annotation.value);

            annotationsTableData.push(annotationRow);
        }

        // Have to show the table prior to populating for its sizing to work correctly.
        $("#IsolationSegmentsAnnotationsTableContainer").show();

        this.isolationSegmentsAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
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
