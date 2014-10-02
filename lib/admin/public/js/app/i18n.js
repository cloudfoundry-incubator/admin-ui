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

function showLanguageMenu() 
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

function toSnakeCase(text) {
    return text.trim()
               .replace( /((?!\b)[A-Z])/g, function(x) { return x.toLowerCase() })
               .replace( /((?!^)[A-Z](?![A-Z]))/g, " $1")
               .replace( /\s+/g, "_")
               .replace( /\%/g, "percentage").toLowerCase();
}

var i18nLocale = {};

function generateI18nAttributesForElement(element, source, prefix) {
    
    var text = element[source]();
    if (!!text.trim()) {
        var i18nId = [prefix, toSnakeCase(text)].join('.');
        element.attr('data-i18n', i18nId);
        if (!(prefix in i18nLocale)) { i18nLocale[prefix] = {} };
        i18nLocale[prefix][toSnakeCase(text)] = element.text();
    }
}

function generateI18nAttributesForNestedElements(rootElement, nestedElementsSelector, source, prefix)
{
    rootElement.find(nestedElementsSelector).each(function(i, element){
        generateI18nAttributesForElement($(element), 'text', prefix);
    });
}

function generateI18nAttributesForMenuBar() {
    generateI18nAttributesForNestedElements($('.menuBar'), '.menuItem', 'text', 'menu_bar')
}

function generateI18nAttributesForDetailsLabel() {
    $('[id$=DetailsLabel]').each(function(i, e) {generateI18nAttributesForElement($(e), 'text', 'details')})
}

function generateI18nAttributesForErrors() {
    $('.error').each(function(i, e) { generateI18nAttributesForElement($(e), 'text', 'error'); })
}

function generateI18nAttributesForPages() {
    var prefix, page;
    $('.page').each(function(i, element){
        page = $(element);
        prefix = toSnakeCase(page.attr('id'));
        generateI18nAttributesForNestedElements(page, 'th', 'text', prefix);
    });
}

$(function() {
  generateI18nAttributesForMenuBar();
  generateI18nAttributesForPages();
  generateI18nAttributesForDetailsLabel();
  generateI18nAttributesForErrors();
  generateI18nAttributesForElement($('.titleBar#userMenu'), 'text', 'title_bar');

  console.log(i18nLocale);
  console.log(JSON.stringify(i18nLocale));

  $('[class*="language"]').mouseover(showLanguageMenu);
  $('[class*="language"]').mouseout(function() { $(".languageMenu").hide(); });  
  $("[data-language]").click(function() { AppI18n.setLocale($(this).data('language')); });
  AppI18n.init();
});


