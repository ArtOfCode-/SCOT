$(document).ready(function () {
  $('.copy-updates-clip').click(function (ev) {
    ev.preventDefault();
    scot.copy('#updates-clip');
    $(this).text('Copied!');
  });
});