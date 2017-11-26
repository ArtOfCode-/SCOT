$(document).ready(function () {
  $('.crew-status-form').on('ajax:success', function (ev) {
    var modal = $(ev.target).parents('.modal');
    var responseData = ev.detail[0];
    var newStatus = responseData.status;

    modal.modal('hide');
    $('.status-name').text(newStatus.name);
  });
});
