$(document).ready(function() {
  $('.notification .close').on('click', function () {
    var id = $(this).parent().data('id');
    $.ajax({
      'type': 'POST',
      'url': '/admin/notifications/' + id + '/read'
    });
  });
});