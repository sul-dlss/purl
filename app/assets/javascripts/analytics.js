GoogleAnalytics = (function() {
  function GoogleAnalytics() {}

  GoogleAnalytics.load = function() {
    if (!GoogleAnalytics.getAnalyticsId() || window.ga) return;

    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
    ga('set', 'anonymizeIp', true);
    ga('create', GoogleAnalytics.getAnalyticsId(), 'auto');
    window.ga = ga;
  }

  GoogleAnalytics.getAnalyticsId = function() {
    return $("[data-analytics-id]").data('analytics-id');
  };
  return GoogleAnalytics;
})();

$(document).on("turbolinks:load", function(){
  GoogleAnalytics.load();

  if (!window.ga) return;

  window.ga('set', 'dimension1', $('link[rel="up"]').attr('href'));
  window.ga('send', 'pageview');
});
