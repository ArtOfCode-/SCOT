$(document).ready(function () {
  $('li, li *').on('mouseenter', function () {
    if ($(this).data('id')) {
      $(this).append($('<a class="section-edit-link mx-2" href="/broadcast/items/' + $(this).data('id') + '/edit"><i class="fa fa-pencil"></i></a>'));
      $(this).append($('<a class="section-del-link mx-1" href="/broadcast/items/' + $(this).data('id') + '/deprecate" data-method="post">'
                     + '<i class="fa fa-times text-danger"></i></a>'));
    }
  }).on('mouseleave', function () {
    if ($(this).data('id')) {
      $(this).children('a.section-edit-link').remove();
      $(this).children('a.section-del-link').remove();
    }
  });

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
});