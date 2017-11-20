$(document).ready(function () {
  $(document).on('shown.bs.modal', function (ev) {
    var id = '#' + $(ev.target).attr('id');
    scot.cad.fillDetailsModal(id);
  });
});