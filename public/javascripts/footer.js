$(document).ready(function() {
  $('.footer-show-hide').toggle(
    function() {
      $('.footer-contents').show();
      $('.footer-show-hide').css('background-image', 'url("/images/icon-img-footer-hide.png")');
    },
    function () {
      $('.footer-contents').hide();
      $('.footer-show-hide').css('background-image', 'url("/images/icon-img-footer-show.png")');
    }
  );
});