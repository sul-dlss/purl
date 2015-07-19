$(document).ready(function() {
  $('.footer-show-hide').toggle(
    function() {
      $this = $(this);

      $('.footer-contents').show();
      $this.css('background-image', 'url("' + $this.data('icon-visible') + '")');
    },
    function () {
      $this = $(this);

      $('.footer-contents').hide();
      $this.css('background-image', 'url("' + $this.data('icon-hidden') + '")');
    }
  );
});