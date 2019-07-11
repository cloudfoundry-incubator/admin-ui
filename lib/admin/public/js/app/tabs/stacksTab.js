
function StacksTab(id)
{
    Tab.call(this, id, Constants.FILENAME__STACKS, Constants.URL__STACKS_VIEW_MODEL);
}

StacksTab.prototype = new Tab();

StacksTab.prototype.constructor = StacksTab;

StacksTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.stacksLabelsTable = Table.createTable("StacksLabels", this.getStacksLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getStacksLabelsActions(), Constants.FILENAME__STACK_LABELS, null, null);

    this.stacksAnnotationsTable = Table.createTable("StacksAnnotations", this.getStacksAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getStacksAnnotationsActions(), Constants.FILENAME__STACK_ANNOTATIONS, null, null);
};

StacksTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

StacksTab.prototype.getColumns = function()
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
                   width:  "200px",
                   render: Format.formatStackName
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
                   title:     "Buildpacks",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Applications",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Application Instances",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Description",
                   width:  "300px",
                   render: Format.formatStringCleansed
               }
           ];
};

StacksTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected stacks?",
                                                         "Delete",
                                                         "Deleting Stacks",
                                                         Constants.URL__STACKS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

StacksTab.prototype.getStacksLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("StacksLabels"),
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

                                          return this.formatCheckbox("StacksLabels", text, value);
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

StacksTab.prototype.getStacksLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("StacksLabels",
                                                         "Are you sure you want to delete the stack's selected labels?",
                                                         "Delete",
                                                         "Deleting Stack Label",
                                                         Constants.URL__STACKS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

StacksTab.prototype.getStacksAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("StacksAnnotations"),
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

                                          return this.formatCheckbox("StacksAnnotations", text, value);
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

StacksTab.prototype.getStacksAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("StacksAnnotations",
                                                         "Are you sure you want to delete the stack's selected annotations?",
                                                         "Delete",
                                                         "Deleting Stack Annotation",
                                                         Constants.URL__STACKS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

StacksTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#StacksLabelsTableContainer").hide();
    $("#StacksAnnotationsTableContainer").hide();
};

StacksTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

StacksTab.prototype.showDetails = function(table, objects, row)
{
    var annotations = objects.annotations;
    var labels      = objects.labels;
    var stack       = objects.stack;
    
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(stack.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(stack.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(stack.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, stack.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Description", Format.formatString, stack.description);
    this.addFilterRowIfValue(table, "Buildpacks", Format.formatNumber,  row[5], stack.name, AdminUI.showBuildpacks);
    this.addFilterRowIfValue(table, "Applications", Format.formatNumber,  row[6], stack.name, AdminUI.showApplications);
    this.addFilterRowIfValue(table, "Application Instances", Format.formatNumber, row[7], stack.name, AdminUI.showApplicationInstances);
    
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
        $("#StacksLabelsTableContainer").show();

        this.stacksLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#StacksAnnotationsTableContainer").show();

        this.stacksAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
};
