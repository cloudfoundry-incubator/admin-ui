
function BuildpacksTab(id)
{
    Tab.call(this, id, Constants.FILENAME__BUILDPACKS, Constants.URL__BUILDPACKS_VIEW_MODEL);
}

BuildpacksTab.prototype = new Tab();

BuildpacksTab.prototype.constructor = BuildpacksTab;

BuildpacksTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.buildpacksLabelsTable = Table.createTable("BuildpacksLabels", this.getBuildpacksLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getBuildpacksLabelsActions(), Constants.FILENAME__BUILDPACK_LABELS, null, null);

    this.buildpacksAnnotationsTable = Table.createTable("BuildpacksAnnotations", this.getBuildpacksAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getBuildpacksAnnotationsActions(), Constants.FILENAME__BUILDPACK_ANNOTATIONS, null, null);
};

BuildpacksTab.prototype.getInitialSort = function()
{
    return [[1, "asc"], [2, "asc"]];
};

BuildpacksTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[2], value);
                                      },
                                      this)
               },
               {
                   title:  "Stack",
                   width:  "200px",
                   render: Format.formatStackName
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatBuildpackName
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
                   title:     "Position",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Enabled",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Locked",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:     "Applications",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               }
           ];
};

BuildpacksTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Rename",
                   click: $.proxy(function()
                                  {
                                      this.renameSingleChecked(this.id,
                                                               "Rename Buildpack",
                                                               "Managing Buildpacks",
                                                               Constants.URL__BUILDPACKS);
                                  },
                                  this)
               },
               {
                   text:  "Enable",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Buildpacks",
                                                         Constants.URL__BUILDPACKS,
                                                         "",
                                                         '{"enabled":true}');
                                  },
                                  this)
               },
               {
                   text:  "Disable",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Buildpacks",
                                                         Constants.URL__BUILDPACKS,
                                                         "",
                                                         '{"enabled":false}');
                                  },
                                  this)
               },
               {
                   text:  "Lock",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Buildpacks",
                                                         Constants.URL__BUILDPACKS,
                                                         "",
                                                         '{"locked":true}');
                                  },
                                  this)
               },
               {
                   text:  "Unlock",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Buildpacks",
                                                         Constants.URL__BUILDPACKS,
                                                         "",
                                                         '{"locked":false}');
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected buildpacks?",
                                                         "Delete",
                                                         "Deleting Buildpacks",
                                                         Constants.URL__BUILDPACKS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

BuildpacksTab.prototype.getBuildpacksLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("BuildpacksLabels"),
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

                                          return this.formatCheckbox("BuildpacksLabels", text, value);
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

BuildpacksTab.prototype.getBuildpacksLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("BuildpacksLabels",
                                                         "Are you sure you want to delete the buildpack's selected labels?",
                                                         "Delete",
                                                         "Deleting Buildpack Label",
                                                         Constants.URL__BUILDPACKS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

BuildpacksTab.prototype.getBuildpacksAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("BuildpacksAnnotations"),
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

                                          return this.formatCheckbox("BuildpacksAnnotations", text, value);
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

BuildpacksTab.prototype.getBuildpacksAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("BuildpacksAnnotations",
                                                         "Are you sure you want to delete the buildpack's selected annotations?",
                                                         "Delete",
                                                         "Deleting Buildpack Annotation",
                                                         Constants.URL__BUILDPACKS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

BuildpacksTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#BuildpacksLabelsTableContainer").hide();
    $("#BuildpacksAnnotationsTableContainer").hide();
};

BuildpacksTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 3);
};

BuildpacksTab.prototype.showDetails = function(table, objects, row)
{
    var annotations = objects.annotations;
    var buildpack   = objects.buildpack;
    var labels      = objects.labels;
    var stack       = objects.stack;

    var first = true;

    if (stack != null)
    {
        this.addFilterRow(table, "Stack", Format.formatStringCleansed(stack.name), stack.guid, AdminUI.showStacks, true);
        this.addPropertyRow(table, "Stack GUID", Format.formatString(stack.guid));

        first = false;
    }

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(buildpack.name), objects, first);
    this.addPropertyRow(table, "GUID", Format.formatString(buildpack.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(buildpack.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, buildpack.updated_at);

    // Initially used priority, then renamed to position
    this.addRowIfValue(this.addPropertyRow, table, "Priority", Format.formatNumber, buildpack.priority);
    this.addRowIfValue(this.addPropertyRow, table, "Position", Format.formatNumber, buildpack.position);

    this.addRowIfValue(this.addPropertyRow, table, "Enabled", Format.formatBoolean, buildpack.enabled);
    this.addRowIfValue(this.addPropertyRow, table, "Locked", Format.formatBoolean, buildpack.locked);
    this.addRowIfValue(this.addPropertyRow, table, "Key", Format.formatString, buildpack.key);
    this.addRowIfValue(this.addPropertyRow, table, "Filename", Format.formatString, buildpack.filename);
    this.addFilterRowIfValue(table, "Applications", Format.formatNumber, row[9], buildpack.guid, AdminUI.showApplications);
    
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
        $("#BuildpacksLabelsTableContainer").show();

        this.buildpacksLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#BuildpacksAnnotationsTableContainer").show();

        this.buildpacksAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
};
