
jQuery.extend(jQuery.fn.dataTableExt.oSort,
{
    "formatted-num-pre": function(a)
    {
        a = ((a === "-") || (a == "")) ? -1 : a.replace(/[^\d\-\.]/g, "");
        return parseFloat(a);
    },

    "formatted-num-asc": function(a, b)
    {
        return a - b;
    },

    "formatted-num-desc": function(a, b)
    {
        return b - a;
    }
});

jQuery.extend(jQuery.fn.dataTableExt.oSort,
{
    "styled-formatted-num-pre": function(a)
    {
        var value = a.substring(a.indexOf(">") + 1, a.length - 7);
        value = ((value === "-") || (value == "")) ? -1 : value.replace(/[^\d\-\.]/g, "");
        return parseFloat(value);
    },

    "styled-formatted-num-asc": function(a, b)
    {
        return a - b;
    },

    "styled-formatted-num-desc": function(a, b)
    {
        return b - a;
    }
});


var Utilities =
{
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

    addPrefix: function(string, prefix, places)
    {
        while (string.length < places)
        {
            string = prefix + string;
        }

        return string;
    },

    formatNumber: function(value)
    {
        if (value != null)
        {
            return (value.toString().indexOf(".") > 0) ? Utilities.addCommasToNumber(value.toFixed(1)) : Utilities.addCommasToNumber(value);
        }

        return "";
    },

    formatDateNumber: function(dateString, showMillis)
    {
        var timestamp = parseInt(dateString);

        return (isNaN(timestamp)) ? dateString : Utilities.formatDate(dateString, showMillis);
    },

    formatDateString: function(dateString)
    {
        var timestamp = Date.parse(dateString);

        if (isNaN(timestamp) && (dateString != null) && (dateString.length > 0))
        {
            dateString = Utilities.fixDateString(dateString);

            timestamp = Date.parse(dateString);
        }

        return (isNaN(timestamp)) ? dateString : Utilities.formatDate(dateString);
    },

    fixDateString: function(dateString)
    {
        dateString = dateString.replace(" +", "+");
        dateString = dateString.replace(" -", "-");

        var stringLength = dateString.length;

        if (stringLength > 2)
        {
            var colonIndex = stringLength - 2;

            if (dateString.charAt(colonIndex) != ":")
            {
                dateString = dateString.substring(0, colonIndex) + ":" + dateString.substring(colonIndex);
            }
        }

        if (dateString.charAt(10) != "T")
        {
            dateString = dateString.substring(0, 10) + "T" + dateString.substring(11);
        }

        return dateString;
    },

    formatDate: function(dateString, showMillis)
    {
  	    if (dateString != null)
  	    {
	          var dateObject = new Date(dateString);
	              
	          var date = "";
	          
	          var MONTHS = [
	                           "Jan",
	                           "Feb",
	                           "Mar",
	                           "Apr",
	                           "May",
	                           "Jun",
	                           "Jul",
	                           "Aug",
	                           "Sep",
	                           "Oct",
	                           "Nov",
	                           "Dec"
	                       ];
	          
	          date += MONTHS[dateObject.getMonth()];
	          date += " ";
	          date += dateObject.getDate();
	          date += ", ";
	          date += dateObject.getFullYear();	      
            date += " ";    
            
            var hour = dateObject.getHours();
            var midday = "AM";
            if (hour > 11)
            { 
                midday = "PM";        
            }
            if (hour > 12)
            { 
                hour = hour - 12; 
            }
            if (hour == 0)
            { 
                hour = 12;        
            }
            date += hour;    
            date += ":";
            
            date += Utilities.addPrefix(dateObject.getMinutes().toString(), "0", 2);
            date += ":";
            
            date += Utilities.addPrefix(dateObject.getSeconds().toString(), "0", 2);
            
            if (showMillis == true)
            {
                var milliseconds = dateObject.getMilliseconds();
                if (milliseconds > 0)
                {
	                  date += ".";
	                  date += Utilities.addPrefix(milliseconds.toString(), "0", 3);
                }
            }

            date += " ";
            date += midday;
	      
	          return date;
	      }
	      
	      return "";
    },

    addCommasToNumber: function(number)
    {
        return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },

    buildStatsData: function(items)
    {
        var usersLine            = [];
        var appsLine             = [];
        var runningInstancesLine = [];
        var totalInstancesLine   = [];
        var deasLine             = [];

        for (var index in items)
        {
            var item = items[index];

            var userEntry             = [];
            var appsEntry             = [];
            var runningInstancesEntry = [];
            var totalInstancesEntry   = [];
            var deasEntry             = [];

            var entryDate = new Date(item.timestamp);

            userEntry.push(entryDate);           
            appsEntry.push(entryDate);
            runningInstancesEntry.push(entryDate);
            totalInstancesEntry.push(entryDate);
            deasEntry.push(entryDate);

            if (item.users > 0)
            {
                userEntry.push(item.users); 
                usersLine.push(userEntry);
            }

            if (item.apps > 0)
            {
                appsEntry.push(item.apps);
                appsLine.push(appsEntry);
            }

            if (item.running_instances > 0)
            {
                runningInstancesEntry.push(item.running_instances);
                runningInstancesLine.push(runningInstancesEntry);
            }

            if (item.total_instances > 0)
            {
                totalInstancesEntry.push(item.total_instances);
                totalInstancesLine.push(totalInstancesEntry);   
            }

            if (item.deas > 0)
            {
                deasEntry.push(item.deas);
                deasLine.push(deasEntry);
            }
        }

        return [totalInstancesLine, runningInstancesLine, appsLine, usersLine];  
    },

    createStatsChart: function(chartID, data)
    {
        return $.jqplot(chartID, 
                        data, 
                        {
                            title: "",
                            animate: true,
                            animateReplot: true,
                            axes:
                            {
                                xaxis:
                                {
                                    renderer: $.jqplot.DateAxisRenderer,
                                    tickRenderer: $.jqplot.CanvasAxisTickRenderer,
                                    tickOptions:
                                    {
                                        formatString: "%b %d"
                                        //formatString: "%b %d %Y"
                                        //angle: -30
                                    }
                                }
                            },
                            series:
                            [
                                Utilities.getChartSeries("rgba(100, 250, 100, 0.7)"),
                                Utilities.getChartSeries("rgba( 50, 170,  50, 1.0)"),
                                Utilities.getChartSeries("rgba(210, 160,   0, 1.0)"),
                                Utilities.getChartSeries("rgba(100, 200, 250, 0.7)")
                            ],
                            legend:
                            {
                                show:true,
                                //placement: "outsideGrid",
                                location: "nw",
                                labels: ["Total Instances", "Running Instances", "Apps", "Users"],
                                renderer: $.jqplot.EnhancedLegendRenderer
                            },
                            highlighter:
                            {
                                show: true,
                                sizeAdjust: 7.5
                            },
                            cursor: 
                            {
                                show: false
                            }
                        });
    },

    getChartSeries: function(rgba)
    {
        var series = {
                         lineWidth: 3, 
                         color: rgba,
                         showMarker: false,
                         rendererOptions:
                         {
                             animation:
                             {                                
                                 speed: 2000 // Default is 3000
                             }
                         }
                     }

        if (rgba != null)
        {
            series.color = rgba;
        }

        return series;
    },

    hideChartSeries: function(chartID, seriesIndices)
    {
        var legend = $("#" + chartID).children(".jqplot-table-legend");

        var legendItems = $(legend).find("td.jqplot-seriesToggle");

        var num = seriesIndices.length;

        for (var index = 0; index < num; index++)
        {
            var legendIndex = seriesIndices[index] * 2;

            var legendItem = legendItems[legendIndex];

            if (document.createEvent) 
            {
                var evt = document.createEvent("HTMLEvents");
                evt.initEvent("click", true, true);
                legendItem.dispatchEvent(evt);
            }
            else
            {      
                var evt = document.createEventObject();
                legendItem.fireEvent("onclick", evt)
            }
        }
    }

};

