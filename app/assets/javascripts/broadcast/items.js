$(document).ready(function () {
  $('.translation-field').hide();

  $('.translation-reveal').click(function (ev) {
    ev.preventDefault();

    if ($(this).data('open') === 'true') {
      $(this).data('open', 'false');
      $(this).text('+ Add translation');
      $('.translation-field').slideUp(500);
      $(this).addClass('mb-4');
    }
    else {
      $(this).data('open', 'true');
      $(this).text('- Remove translation');
      $('.translation-field').slideDown(500);
      $(this).removeClass('mb-4');
    }
  });

  $('.select-today').click(function (ev) {
    ev.preventDefault();

    var dateSelect = $($(this).data('for'));
    var date = new Date();

    dateSelect.eq(0).val(date.getFullYear());
    dateSelect.eq(1).val(date.getMonth());
    dateSelect.eq(2).val(date.getDay());
    dateSelect.eq(3).val(date.getHours());
    dateSelect.eq(4).val(date.getMinutes().toString().padStart(2, '0'));
  });
});