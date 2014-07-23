var AppI18n = {
  currentLocale: null,
  setLocale: function(lng) {
  	$.cookie('lng', lng)
    i18n.init({
      fallbackLng: 'en',
      resGetPath: 'locales/__lng__.json',
      lng: lng
    }, function() { $("body").i18n(); });
    var languageName = $("[data-language=" + lng + "]").text();
    $('.languageContainer .languageName').text(languageName);
    AppI18n.currentLocale = lng;
  },
  init: function() {
    if (AppI18n.currentLocale == null) {
      var lng = $.cookie('lng');
      if (typeof(lng) === 'undefined') { lng = 'en' }
      AppI18n.setLocale(lng);
    }
  }
}

if(typeof(AdminUI) === 'undefined') { AdminUI = {} }
AdminUI['showLanguageMenu'] = function()
{
    var position = $(".languageContainer").position();
    var height = $(".languageContainer").outerHeight();
    var width  = $(".languageContainer").outerWidth();
    var menuWidth = $(".languageMenu").outerWidth();
    $(".languageMenu").css({
                           position: "absolute",
                           top: (position.top + height + 2) + "px",
                           left: (position.left + width - menuWidth) + "px"
                       }).show();
}


$(function() {
  $('[class*="language"]').mouseover(AdminUI.showLanguageMenu);
  $('[class*="language"]').mouseout(function() { $(".languageMenu").hide(); });  
  $("[data-language]").click(function() { AppI18n.setLocale($(this).data('language')); });

  AppI18n.init();
});
