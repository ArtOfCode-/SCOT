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

var $root = $('html, body');

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
  }

  errorAlert: function (text, under) {
    $(under).append('<div class="alert alert-danger">' + text + '</div>');
  },

  scrollToAnchor: function (anchor) {
    $root.animate({
      scrollTop: $(anchor).offset().top
    }, 500, function () {
      window.location.hash = anchor;
    });
  },

  cad: {
    cache: { requests: {}, requestPanels: {} },

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
    },

    submitNextStep: function () {
      var acc = $('#form-accordion');
      if (!acc || acc.length === 0) {
        return;
      }

      var currentSection = acc.find('.collapse.show');
      var currentTitle = currentSection.siblings('a').first();
      var nextSection = currentSection.parents('.acc-item').nextAll('.acc-item').eq(0).find('.collapse');
      var nextTitle = nextSection.siblings('a').first();

      var currentIcon = currentTitle.find('.section-icon');
      currentIcon.removeClass('fa-spinner').addClass('fa-check text-success');
      var currentCaret = currentTitle.find('.section-caret');
      currentCaret.removeClass('fa-caret-down').addClass('fa-caret-right');

      var nextIcon = nextTitle.find('.section-icon');
      nextIcon.addClass('fa-spinner');
      var nextCaret = nextTitle.find('.section-caret');
      nextTitle.find('.section-caret').removeClass('fa-caret-right').addClass('fa-caret-down');

      currentSection.collapse('hide');
      nextSection.collapse('show');
    },

    reverseGeocode: function (lat, long, key) {
      $.ajax({
        type: 'GET',
        url: 'https://maps.googleapis.com/maps/api/geocode/json?latlng=' + lat + ',' + long + '&key=' + key
      })
      .done(function (data) {
        if (!data.results || data.results.length === 0) {
          return;
        }

        var typeFilter = function (type) {
          var results = data.results[0].address_components.filter(function (el) { return el.types.indexOf(type) > -1; });
          return results.length !== 0 ? results[0] : { short_name: '', long_name: '' };
        };

        $('#street_address').val(typeFilter('street_number').short_name + ' ' + typeFilter('route').long_name);
        $('#city').val(typeFilter('administrative_area_level_2').long_name);
        $('#state').val(typeFilter('administrative_area_level_1').long_name);
        $('#zip_code').val(typeFilter('postal_code').long_name);
        $('#country').val(typeFilter('country').long_name);
      })
      .fail(function (jqXHR, textStatus) {
        scot.errorAlert(jqXHR.status + ': ' + textStatus, '#section-1');
      });
    },

    RequestPanel: function (id) {
      var cached = scot.cad.cache.requestPanels[parseInt(id, 10)];
      if (cached) {
        return cached;
      }

      this.id = parseInt(id, 10);
      this.column = $('.cad-panel[data-request-id=' + id + ']');
      this.card = this.column.children('.card');
      this.buttons = this.card.find('.request-buttons');
      this.spinner = $('.cad-panel[data-request-id=' + id + '] .request-spinner');

      this.resources = {};
      this.resources.container = this.card.find('.request-resources');
      this.resources.list = this.resources.container.find('.resources-list');

      this.map = {};
      this.map.el = this.card.find('.map');
      this.map.gmap = $(this.map.el).data('map');
      this.map.marker = $(this.map.el).data('marker');

      this.status = this.card.find('.request-status');
      this.priority = this.card.find('.request-priority');
      this.crew = this.card.find('.assigned-crew');

      this.doVisibleUpdate = function (duration) {
        this.spinner.css('visibility', 'visible');
        this.card.addClass('request-disabled');
        var self = this;
        setTimeout(function () {
          self.spinner.css('visibility', 'hidden');
          self.card.removeClass('request-disabled');
        }, duration);
      };

      this.updateCrew = function (crew) {
        var displayName = crew.callsign + ' (' + crew.contact_name + ')';
        if (this.crew.length > 0) {
          this.crew.text(displayName);
        }
        else {
          this.card.find('.statuses').after('<p><strong>Assigned Crew:</strong> <span class="assigned-crew">' + displayName  + '</span>')
          this.crew = this.card.find('.assigned-crew');
        }
      };

      this.updateStatus = function (status) {
        console.log(status);
        this.status.html('<strong class="text-' + status.color + '" title="' + status.description + '">Status: <i class="fa fa-fw fa-' +
                         status.icon + '"></i> ' + status.name + '</strong>');
        this.status.tooltip();
        this.map.marker.setIcon(markerPath(status.color));
      };

      this.updateButtons = function (buttons) {
        this.buttons.find('[data-toggle=tooltip]').tooltip('hide');
        this.buttons.html(buttons);
      };

      this.addResource = function (resource) {
        if (this.resources.container.length === 0) {
          this.buttons.before('<div class="request-resources"><strong>Resources:</strong><br/><ol class="resources-list"></ol></div>');
          this.resources.container = this.card.find('.request-resources');
          this.resources.list = this.resources.container.find('.resources-list');
        }
        this.resources.list.append('<li><strong>' + resource.name + '</strong> (' + resource.resource_type.name + ')</li>');
      };

      this.getName = function () {
        return this.card.find('.request-name').text();
      };

      this.getStatusIndex = function () {
        return parseInt(this.status.data('index'), 10);
      };

      this.getPriorityIndex = function () {
        return parseInt(this.priority.data('index'), 10);
      }
    }
  }
};

Object.filter = function (obj, predicate) {
  var results = {};
  for (var key in obj) {
    if (obj.hasOwnProperty(key) && predicate(obj[key])) {
      results[key] = obj[key];
    }
  }
  return results;
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
