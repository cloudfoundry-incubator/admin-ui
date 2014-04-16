
var Format =
{
    raw: false,

    doFormatting: function(type)
    {
        if (Format.raw)
        {
            return false;
        }
        
        return ((type == null) || (type == "display"));
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

    formatApplicationName: function(name, type, item)
    {
        return Format.formatTruncatedString(name, type, item, 30);
    },

    formatAvailableCapacity: function(capacity, type, item)
    {
        if (Format.doFormatting(type))
        {
            var color = "rgb(0, 190, 0)";

            if (capacity < 5)
            {
                color = "rgb(200, 0, 0)";
            }
            else if (capacity < 10)
            {
                color = "rgb(250, 100, 0)";
            }
            else if (capacity < 20)
            {
                color = "rgb(170, 160, 0)";
            }

            return "<span style='color: " + color + ";'>" + capacity + "</span>";
        }
        else
        {
            return capacity;
        }
    },

    formatBuildpacks: function(buildpacks, type, item)
    {
        if (Format.doFormatting(type))
        {
            var result = "";

            if (buildpacks != null)
            {
                var first = true;

                var buildpackArray = buildpacks.split(",");

                for (var buildpackIndex = 0; buildpackIndex < buildpackArray.length; buildpackIndex++)
                {
                    if (first)
                    {
                        first = false;
                    }
                    else
                    {
                        result += "<br/>";
                    }

                    var buildpack = buildpackArray[buildpackIndex];

                    if (type == "display")
                    {
                        result += "<span title=\"" + buildpack + "\">";

                        if (buildpack.length > 20)
                        {
                            result += buildpack.substring(0, 20) + "...";
                        }
                        else
                        {
                            result += buildpack;
                        }

                        result += "</span>";
                    }
                    else
                    {
                        result += buildpack;
                    }
                }
            }

            return result;
        }
        else
        {
            return buildpacks;
        }
    },

    formatApplications: function(applications, type, item)
    {
        if (Format.doFormatting(type))
        {
            var result = "";

            if (applications != null)
            {
                var first = true;

                for (var appIndex = 0; appIndex < applications.length; appIndex++)
                {
                    if (first)
                    {
                        first = false;
                    }
                    else
                    {
                        result += "<br/>";
                    }

                    var app = applications[appIndex];

                    if (type == "display")
                    {
                        result += "<span title=\"" + app + "\">";

                        if (app.length > 20)
                        {
                            result += app.substring(0, 20) + "...";
                        }
                        else
                        {
                            result += app;
                        }

                        result += "</span>";
                    }
                    else
                    {
                        result += app;
                    }
                }
            }

            return result;
        }
        else
        {
            return applications;
        }
    },

    formatBoolean: function(value)
    {
        return (value) ? "true" : "false";
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
            
            date += Utilities.padNumber(dateObject.getMinutes(), 2);
            date += ":";
            
            date += Utilities.padNumber(dateObject.getSeconds(), 2);
            
            if (showMillis == true)
            {
                var milliseconds = dateObject.getMilliseconds();
                if (milliseconds > 0)
                {
                    date += ".";
                    date += Utilities.padNumber(milliseconds, 3);
                }
            }

            date += " ";
            date += midday;
	      
            return date;
        }
	      
        return "";
    },

    formatDateNumber: function(dateString, showMillis)
    {
        var timestamp = parseInt(dateString);

        return (isNaN(timestamp)) ? dateString : Format.formatDate(dateString, showMillis);
    },

    formatDateString: function(dateString)
    {
        var timestamp = Date.parse(dateString);

        if (isNaN(timestamp) && (dateString != null) && (dateString.length > 0))
        {
            dateString = Format.fixDateString(dateString);

            timestamp = Date.parse(dateString);
        }

        return (isNaN(timestamp)) ? dateString : Format.formatDate(dateString);
    },

    formatIconImage: function(url)
    {
        if (! url) 
        {
           return "";
        }
        var html = "<div  style='{2}'><img class='icon-image' src='{0}' alt='{1}'></div>";
        var altText = (arguments.length >= 2) ? arguments[1]: '';
        var style   = (arguments.length >= 3) ? arguments[2]: '';
        html = Utilities.localize(html, [url, altText, style]);
        return html;
    },

    formatNumber: function(value, type, item)
    {
        var result = "";

        if (value != null)
        { 
            if (Format.doFormatting(type))
            {
                result = (value.toString().indexOf(".") > 0) ? Utilities.addCommasToNumber(value.toFixed(1)) : Utilities.addCommasToNumber(value);
            }
            else if ((value === "") && (type == "sort"))
            {
                result = -1;
            }
            else
            {
                result = value;
            }
        }

        return result;
    },

    formatOrganizationName: function(name, type, item)
    {
        return Format.formatTruncatedString(name, type, item, 20);
    },

    formatOrganizationStatus: function(status, type, item)
    {
        if (Format.doFormatting(type))
        {
            var result = "<span";

            if (status != "active")
            {
                result += " style='color: rgb(200, 0, 0);'";
            }

            result += ">" + Format.formatString(status).toUpperCase();

            result += "</span>";

            return result;
        }
        else
        {
            return Format.formatString(status).toUpperCase();
        }
    },

    formatServiceString: function(name, type, item)
    {
        return Format.formatTruncatedString(name, type, item, 30);
    },

    formatSpaceName: function(name, type, item)
    {
        return Format.formatTruncatedString(name, type, item, 20);
    },

    formatStacks: function(values, type, item)
    {
        if (Format.doFormatting(type))
        {
            var result = "";

            if (values != null)
            {
                var first = true;

                for (var valueIndex in values)
                {
                    if (first)
                    {
                        first = false;
                    }
                    else
                    {
                        result += "<br/>";
                    }

                    var value = values[valueIndex];

                    if (type == "display")
                    {
                        result += "<span title=\"" + value + "\">";

                        if (value.length > 14)
                        {
                            result += value.substring(0, 14) + "...";
                        }
                        else
                        {
                            result += value;
                        }

                        result += "</span>";
                    }
                    else
                    {
                        result += value;
                    }
                }
            }

            return result;
        }
        else
        {
            return values;
        }
    },

    formatStatus: function(status, type, item)
    {
        if (Format.doFormatting(type))
        {
            var result = "<span";

            if ((status == Constants.STATUS__STOPPED) ||
                (status == Constants.STATUS__FAILED)  ||
                (status == Constants.STATUS__OFFLINE))
            {
                result += " style='color: rgb(200, 0, 0);'";
            }

            result += ">" + status;

            if (status == Constants.STATUS__OFFLINE)
            {
                result += " <img src='images/remove.png' onclick='AdminUI.removeItemConfirmation(\"" + item[item.length - 1] + "\")' class='removeButton' title='Remove " + item[item.length - 1] + "'/>";
            }

            result += "</span>";

            return result;
        }
        else
        {
            return status;
        }
    },

    formatString: function(value)
    {
        return (value != null) ? value : "";
    },

    formatTarget: function(name, type, item)
    {
        return Format.formatTruncatedString(name, type, item, 30);
    },

    formatTruncatedString: function(value, type, item, length)
    {
        var result = "";

        if (value != null)
        {
            if (Format.doFormatting(type))
            {
                result += "<span title=\"" + value + "\">";

                if (value.length > length)
                {
                    result += value.substring(0, length) + "...";
                }
                else
                {
                    result += value;
                }

                result += "</span>";
            }
            else
            {
                result += value;
            }
        }

        return result;
    },

    formatUptime: function(uptime)
    {
        var result = "";

        if (uptime != null)
        {
            var sections = uptime.split(":");

            if (sections.length == 4)
            {
                sections[0] = parseInt(sections[0].replace("d", ""));
                sections[1] = parseInt(sections[1].replace("h", ""));
                sections[2] = parseInt(sections[2].replace("m", ""));
                sections[3] = parseInt(sections[3].replace("s", ""));

                result = sections[0].toString();

                if (sections[0] == 1)
                {
                    result += " day, ";
                }
                else
                {
                    result += " days, ";
                }

                result += Utilities.padNumber(sections[1], 2) + ":";
                result += Utilities.padNumber(sections[2], 2) + ":";
                result += Utilities.padNumber(sections[3], 2);
            }
        }

        return result;
    },

    formatURIs: function(values, type, item)
    {
        if (Format.doFormatting(type))
        {
            var result = "";

            if (values != null)
            {
                var first = true;

                for (var valueIndex in values)
                {
                    if (first)
                    {
                        first = false;
                    }
                    else
                    {
                        result += "<br/>";
                    }

                    var value = "http://" + values[valueIndex];

                    if (type == "display")
                    {
                        result += "<span title=\"" + value + "\">";

                        if (value.length > 40)
                        {
                            result += value.substring(0, 40) + "...";
                        }
                        else
                        {
                            result += value;
                        }

                        result += "</span>";
                    }
                    else
                    {
                        result += value;
                    }
                }
            }

            return result;
        }
        else
        {
            return values;
        }
    }
}

