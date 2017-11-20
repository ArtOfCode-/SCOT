// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require_tree .

window.scot = {
  initialize: function () {
    $('[data-toggle="tooltip"]').tooltip();
  },

  copy: function (elId) {
    var el = $(elId);
    el.show();
    el.select();
    var success = document.execCommand('copy');
    if (success) {
      el.hide();
    }
  },

  formatItem: function (item) {
    if (!item.id) {
      return item.content;
    }

    var text = item.content.substr(0, 100);
    if (text.length === 100) {
      text = text + '...';
    }

    return $(
      '<div><strong>#' + item.id + '</strong><br/>' + text + '</div>'
    );
  },

  errorAlert: function (text, under) {
    $(under).append('<div class="alert alert-danger">' + text + '</div>');
  },

  cad: {
    cache: { requests: {} },

    fillDetailsModal: function (id) {
      var modal = $(id);
      var requestId = modal.data('request-id'),
          disasterId = modal.data('disaster-id');
      $.ajax({
        type: 'GET',
        url: '/cad/' + disasterId + '/' + requestId + '.json'
      })
      .done(function (data) {
        scot.cad.cache.requests[requestId] = data;
        modal.find('.extra-details').text(data.extra_details);
        modal.find('.medical-details').text(data.medical_details);
      })
      .fail(function (jqXHR, textStatus, errorThrown) {
        scot.errorAlert(jqXHR.status + ': ' + textStatus, modal.find('.extra-details'));
      });
    }
  }
};

$(document).ready(function() {
  scot.initialize();

  $('.slide-body').hide();

  $('.slide-header').on('click', function() {
    $(this).siblings('.slide-body').slideToggle(250);
  });

  $('.select2').select2({
    theme: 'bootstrap',
    allowClear: true,
    closeOnSelect: $(this).hasClass('multiple')
  });

  $('.select2-dedupe').select2({
    theme: 'bootstrap',
    ajax: {
      url: '/translations/dedupe/data',
      dataType: 'json'
    },
    templateResult: scot.formatItem,
    minimumInputLength: 1
  });

  date = $('.datepicker').val();

  if (date === null) {
    date = new Date();
  }

  new Pikaday({
    field: $('.datepicker')[0],
    showTime: true,
    showSeconds: false,
    use24hour: true,
    defaultDate: date,
    setDefaultDate: true,
    toString: function (date, format) {
      return date.toISOString();
    },
    onOpen: function () {
      $('.pika-time .pika-select').addClass('form-control');
    }
  });

  $('.s2-all').on('click', function (ev) {
    var targetSelector = $(ev.target).data('target');
    $(targetSelector + ' > option').attr('selected', 'selected');
    $(targetSelector).trigger('change');
  });

  $('.s2-none').on('click', function (ev) {
    var targetSelector = $(ev.target).data('target');
    $(targetSelector + ' > option').removeAttr('selected');
    $(targetSelector).trigger('change');
  });
});
