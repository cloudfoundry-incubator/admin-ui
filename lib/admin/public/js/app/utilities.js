
var Utilities =
{
    addCommasToNumber: function(number)
    {
        return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },

    addEmptyElementsToArray: function(array, number)
    {
        for (var entryIndex = 0; entryIndex < number; entryIndex++)
        {
            array.push("");
        }
    },

    addZeroElementsToArray: function(array, number)
    {
        for (var entryIndex = 0; entryIndex < number; entryIndex++)
        {
            array.push(0);
        }
    },

    convertBytesToMega: function(number)
    {
        return Math.round(number / 1048576);
    },

    padNumber: function(number, size)
    {
        var numberString = number.toString();

        while (numberString.length < size) numberString = "0" + numberString;

        return numberString;
    },

    localize: function (message, params) 
    {
        var locMessage = message;
        for (var i = 0, count = params.length; i < count; i++) 
        {
            var param = params[i];
            if (param == null) 
            {
                break;
            }
            var varSymbol = "{" + i + "}";
            locMessage    = locMessage.replace(varSymbol, params[i]);
        }
        return locMessage;
    },

    localizeSequence: function(message, separator, params)
    {
        var locMessage      = message;
        var sequenceString  = params[0];
        for (var i = 1, count = params.length; i < count; i++)
        {
            var param = params[i];
            if (param == null) 
            {
                break;
            }
            sequenceString += separator + param;
        }
        var varSymbol = "{n}";
        locMessage    = locMessage.replace(varSymbol, sequenceString);
        return locMessage;
    }
};
