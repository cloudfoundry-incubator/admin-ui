// Have to reassign the swfPath in order for allowScriptAccess="sameDomain" to function below
$.fn.dataTable.Buttons.swfPath = "js/external/jquery/Buttons-1.5.1/swf/flashExport.swf";

ZeroClipboard_TableTools.Client.prototype.getHTML = function(width, height) {
    // return HTML for movie
    var html = '';
    var flashvars = 'id=' + this.id +
        '&width=' + width +
        '&height=' + height;

    if (navigator.userAgent.match(/MSIE/)) {
        // IE gets an OBJECT tag
        var protocol = location.href.match(/^https/i) ? 'https://' : 'http://';
        html += '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="'+protocol+'download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0" width="'+width+'" height="'+height+'" id="'+this.movieId+'" align="middle"><param name="allowScriptAccess" value="sameDomain" /><param name="allowFullScreen" value="false" /><param name="movie" value="'+ZeroClipboard_TableTools.moviePath+'" /><param name="loop" value="false" /><param name="menu" value="false" /><param name="quality" value="best" /><param name="bgcolor" value="#ffffff" /><param name="flashvars" value="'+flashvars+'"/><param name="wmode" value="transparent"/></object>';
    }
    else {
        // all other browsers get an EMBED tag
        html += '<embed id="'+this.movieId+'" src="'+ZeroClipboard_TableTools.moviePath+'" loop="false" menu="false" quality="best" bgcolor="#ffffff" width="'+width+'" height="'+height+'" name="'+this.movieId+'" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" flashvars="'+flashvars+'" wmode="transparent" />';
    }
    return html;
}
