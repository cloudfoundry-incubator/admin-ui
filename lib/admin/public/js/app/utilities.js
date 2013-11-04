
var Utilities =
{
    addCommasToNumber: function(number)
    {
        return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },

    addEmptyElementsToArray: function(array, number)
    {
        for (var index = 0; index < number; index++)
        {
            array.push("");
        }
    },

    addZeroElementsToArray: function(array, number)
    {
        for (var index = 0; index < number; index++)
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
    }
};

