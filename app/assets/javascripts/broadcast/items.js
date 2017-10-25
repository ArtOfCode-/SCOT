$(document).ready(function () {
  $('li, li *').on('mouseenter', function () {
    if ($(this).data('id')) {
      $(this).children('a.section-edit-link').show();
      $(this).children('a.section-del-link').show();
    }
  }).on('mouseleave', function () {
    if ($(this).data('id')) {
      $(this).children('a.section-edit-link').hide();
      $(this).children('a.section-del-link').hide();
    }
  });

  $('li a.section-edit-link, li a.section-del-link').hide();

  $('.field-grid .field > textarea').on('focus', function () {
    if ($(this).hasClass('left')) {
      $(this).parents('.field-grid').css({
        'grid-template-columns': '2fr 1fr'
      });
    }
    else {
      $(this).parents('.field-grid').css({
        'grid-template-columns': '1fr 2fr'
      });
    }
  }).on('blur', function () {
    $(this).parents('.field-grid').css({
      'grid-template-columns': '1fr 1fr'
    });
  });

  $(document).on('shown.bs.modal', function (ev) {
    var modal = $(ev.target);
    var caller = $(ev.relatedTarget);

    if (modal.hasClass('item-info')) {
      var id = caller.data('id');
      if (caller.hasClass('notes-link')) {
        $("#notes-tab-" + id).tab('show');
      }
      else if (caller.hasClass('full-text-link')) {
        $("#content-tab" + id).tab('show');
      }
    }
  });
});