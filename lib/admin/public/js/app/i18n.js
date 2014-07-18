// i18n.init(function(t) {
//   $("body").i18n({'fallbackLng': 'en'});
// });
$(document).ready(function() {
	i18n.init({fallbackLng: 'en', resGetPath: 'locales/__lng__.json', lng: 'ru'}, function() { $("body").i18n(); });
});
