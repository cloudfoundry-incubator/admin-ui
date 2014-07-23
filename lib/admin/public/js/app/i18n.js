var AppI18n = {
  setLocale: function(lng) {
  	$.cookie('lng', lng)
    i18n.init({
      fallbackLng: 'en',
      resGetPath: 'locales/__lng__.json',
      lng: lng
    }, function() { $("body").i18n(); });

    var languageName = $("[data-language=" + lng + "]").text();
    $('.languageContainer .languageName').text(languageName);
  }
}

$(document).ready(function() {
  $('[class*="language"]').mouseover(AdminUI.showLanguageMenu);
  $('[class*="language"]').mouseout(function() { $(".languageMenu").hide(); });  
  $("[data-language]").click(function() { AppI18n.setLocale($(this).data('language')); });

  var lng = $.cookie('lng');
  if (typeof(lng) === 'undefined') { lng = 'en' }
  AppI18n.setLocale(lng);
});
