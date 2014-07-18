$(document).ready(function() {
	i18n.init(
		{fallbackLng: 'en', resGetPath: 'locales/__lng__.json'}, 
		function() { $("body").i18n();
	});
});
