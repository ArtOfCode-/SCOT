window.scot = window.scot || {};
scot.cad = {
  cache: { requests: {}, requestPanels: {}},

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
          var results = data.results[0].address_components.filter(function (el) {
            return el.types.indexOf(type) > -1;
          });
          return results.length !== 0 ? results[0] : {short_name: '', long_name: ''};
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
        this.card.find('.statuses').after('<p><strong>Assigned Crew:</strong> <span class="assigned-crew">' + displayName + '</span>')
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
};

$(document).ready(function () {
  $('.cad-panel').each(function(i, el) {
    var requestId = $(el).data('request-id');
    scot.cad.cache.requestPanels[parseInt(requestId, 10)] = new scot.cad.RequestPanel(requestId);
  });

  $(document).on('shown.bs.modal', function (ev) {
    if (!$(ev.target).hasClass('list-modal')) {
      return;
    }
    var id = '#' + $(ev.target).attr('id');
    scot.cad.fillDetailsModal(id);
  });

  $('.next-section').on('click', function () {
    scot.cad.submitNextStep();
  });

  $(document).on('show.bs.collapse', function (ev) {
    var title = $(ev.target).siblings('a').first();
    var caret = title.find('.section-caret');
    caret.removeClass('fa-caret-right').addClass('fa-caret-down');
  });

  $(document).on('hide.bs.collapse', function (ev) {
    var title = $(ev.target).siblings('a').first();
    var caret = title.find('.section-caret');
    caret.removeClass('fa-caret-down').addClass('fa-caret-right');
  });

  var geoSuccess = function(position) {
    var lat = position.coords.latitude;
    var long = position.coords.longitude;
    console.log('geolocation.success', lat, long);
    moveToSecondStage(lat, long);
  };

  var locationTrigger = document.getElementById('use-my-location');
  if (locationTrigger) {
    locationTrigger.addEventListener('click', function(evt) {
      evt.preventDefault();
      navigator.geolocation.getCurrentPosition(geoSuccess);
    });
  }

  $('.request-submit').on('click', function (ev) {
    var requiredInputs = $('form input[required]');
    if (requiredInputs.toArray().some(function (el) { return !$(el).val(); })) {
      ev.preventDefault();
      var problems = requiredInputs.filter(function (i, el) { return !$(el).val(); });
      problems.each(function (i, el) {
        $(el).addClass('is-invalid');
        $(el).nextAll('.invalid-feedback').show();
      });
      var firstProblem = $(problems[0]);
      var problemSection = firstProblem.parents('.section.collapse').first();
      problemSection.collapse('show');
      scot.scrollToAnchor('#' + firstProblem.attr('id'));
    }
  });

  $('.select2-cad-crew').each(function (i, el) {
    $.ajax({
      type: 'GET',
      url: crewsUri($(el).parents('.modal'))
    })
    .done(function (data) {
      var options = {
        theme: 'bootstrap',
        data: data.results,
        dropdownParent: $(el).parents('.modal').first()
      };
      $(el).select2(options);
    })
    .fail(function (jqXHR, textStatus) {
      scot.errorAlert(jqXHR.status + ': ' + textStatus, $(el).parents('.modal').first());
    });
  });

  $('.crew-select-update').on('change', function (ev) {
    var select = $(ev.target).parents('.modal-body').find('.select2-cad-crew');
    select.children('option').remove();

    $.ajax({
      type: 'GET',
      url: crewsUri(select.parents('.modal'))
    })
    .done(function (data) {
      var options = {
        theme: 'bootstrap',
        data: [{id: -1, text: ''}].concat(data.results),
        dropdownParent: select.parents('.modal').first()
      };
      select.select2(options);
    })
    .fail(function (jqXHR, textStatus) {
      scot.errorAlert(jqXHR.status + ': ' + textStatus, select.parents('.modal').first());
    });
  });

  $(document).on('ajax:success', '.close-request', function (ev) {
    ev.stopPropagation();
    $(ev.target).parents('.cad-panel').fadeOut(200, function () { $(this).remove(); });
  });

  $(document).on('ajax:success', '.dispatch-crew-form', function (ev) {
    ev.stopPropagation();
    var modal = $(ev.target).parents('.modal');
    modal.modal('hide');

    var requestId = modal.data('request-id');
    var request = new scot.cad.RequestPanel(requestId);
    var responseData = ev.detail[0];

    request.updateCrew(responseData.crew);
    request.updateStatus(responseData.status);
    request.updateButtons(responseData.buttons);
    request.doVisibleUpdate(400);
  });

  $(document).on('ajax:success', '.request-on-scene', function (ev) {
    ev.stopPropagation();
    var request = new scot.cad.RequestPanel($(ev.target).parents('.cad-panel').data('request-id'));
    var responseData = ev.detail[0];
    request.updateStatus(responseData.status);
    request.updateButtons(responseData.buttons);
    request.doVisibleUpdate(200);
  });

  $(document).on('shown.bs.modal', '.relief-center, .rest-stop', function (ev) {
    var requestId = $(ev.target).data('request-id');
    var ajaxEndpoint = $(ev.target).data('ajax');
    $.ajax({
      type: 'GET',
      url: ajaxEndpoint + '?request_id=' + requestId
    })
      .done(function (data) {
        var mapContainer = $(ev.target).find('.cad-resource-map');
        var center = mapContainer.data('center').split(',');
        var location = { lat: parseFloat(center[0]), lng: parseFloat(center[1]) };

        var map = new google.maps.Map(mapContainer[0], {
          center: location,
          zoom: 8
        });
        var requestMarker = new google.maps.Marker({
          position: location,
          map: map,
          icon: markerPath('danger'),
          title: 'Request'
        });
        mapContainer.data('map', map).data('request-marker', requestMarker);

        $.each(data.results, function (i, el) {
          var location = { lat: parseFloat(el.lat), lng: parseFloat(el.long) };
          var marker = new google.maps.Marker({
            position: location,
            map: map,
            icon: markerPath('success'),
            title: el.text
          });
          marker.addListener('click', function () {
            marker.setAnimation(google.maps.Animation.BOUNCE);
            setTimeout(function () {
              marker.setAnimation(null);
            }, 1400);
            var select = $(ev.target).find('.select2-cad-resource');
            select.val(el.id);
            select.trigger('change');
          });
        });

        $(ev.target).find('.select2-cad-resource').select2({
          theme: 'bootstrap',
          data: data.results
        });
      })
      .fail(function (jqXHR, textStatus) {
        scot.errorAlert(jqXHR.status + ': ' + textStatus, $(ev.target).find('.modal-body'));
      });
  });

  $(document).on('ajax:success', '.dispatch-resource-form', function (ev) {
    var modal = $(ev.target).parents('.modal');
    var requestId = modal.data('request-id');
    modal.modal('hide');

    var request = new scot.cad.RequestPanel(requestId);
    var responseData = ev.detail[0];
    request.addResource(responseData.resource);
    request.updateButtons(responseData.buttons);
    request.doVisibleUpdate(300);
  });

  $(document).on('ajax:success', '.request-safe', function (ev) {
    var request = new scot.cad.RequestPanel($(ev.target).parents('.cad-panel').data('request-id'));
    var responseData = ev.detail[0];
    request.updateStatus(responseData.status);
    request.updateButtons(responseData.buttons);
    request.doVisibleUpdate(200);
  });

  $('.request-details-link').on('click', function (ev) {
    ev.preventDefault();
    var modal = $($(ev.target).data('target'));
    modal.find('.' + $(ev.target).data('tab') + '-tab').tab('show');
  });

  $('#cad-search').on('keyup', function (ev) {
    var query = $(ev.target).val();
    $('.cad-panel, .cad-panel-search-hidden').show().removeClass('cad-panel-search-hidden');
    var filtered = Object.filter(scot.cad.cache.requestPanels, function (panel) {
      if (query.indexOf('#') === 0) {
        var id = parseInt(query.split(' ')[0].replace('#', ''), 10);
        if (id) {
          return panel.id !== id;
        }
      }
      else {
        return panel.getName().indexOf(query) === -1;
      }
    });
    $.each(filtered, function (i, panel) {
      panel.column.hide();
    });
    resolveGrid();
  });
});

function resolveGrid() {
  var visiblePanels = $('.cad-panel').filter(':visible').removeClass('cad-panel').addClass('cad-panel-search-hidden');
  var rows = $('.cad-grid-row');
  visiblePanels.sort(function (a, b) {
    var aId = $(a).data('request-id');
    var bId = $(b).data('request-id');

    var aReq = new scot.cad.RequestPanel(aId);
    var bReq = new scot.cad.RequestPanel(bId);

    var aSortIndex = aReq.getStatusIndex() + aReq.getPriorityIndex();
    var bSortIndex = bReq.getStatusIndex() + bReq.getPriorityIndex();

    if (aSortIndex < bSortIndex) {
      return -1;
    }
    else if (aSortIndex === bSortIndex) {
      return 0;
    }
    else {
      return 1;
    }
  }).each(function (i, el) {
    for (var ri = 0; ri < rows.length; ri++) {
      var row = rows[ri];
      if ($(row).find('.cad-panel').length < 3) {
        $(el).detach().appendTo(row);
      }
    }
  });
}

function markerPath(name) {
  return $("a[data-name=" + name + "]").attr('href');
}

function moveToSecondStage(lat, lng) {
  $('#rescue_request_lat').val(lat);
  $('#rescue_request_long').val(lng);
  scot.cad.reverseGeocode(lat, lng, $('#section-1').data('key'));
  scot.cad.submitNextStep();
}

function initMap() {
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 6,
    center: {lat: 29.5909775, lng: -93.9997136}
  });

  var input = document.getElementById('autocomplete');
  var autocomplete = new google.maps.places.Autocomplete(input);
  autocomplete.addListener('place_changed', function () {
    var place = autocomplete.getPlace().geometry.location;
    var lat = place.lat();
    var long = place.lng();
    moveToSecondStage(lat, long);
  });

  google.maps.event.addListener(map, 'click', function (event) {
    var lat = event.latLng.lat();
    var long = event.latLng.lng();
    moveToSecondStage(lat, long);
  });
}

function initShowMap() {
  var mapContainer = $('#map');
  var center = mapContainer.data('center').split(',');
  var markerType = mapContainer.data('marker-type');
  var image = markerPath(markerType);
  var location = { lat: parseFloat(center[0]), lng: parseFloat(center[1]) };
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 9,
    center: location
  });
  var marker = new google.maps.Marker({
    position: location,
    map: map,
    icon: image
  });
}

function initCadMaps() {
  var maps = $('.map');
  maps.each(function (i, el) {
    var container = $(el);
    var center = container.data('center').split(',');
    var location = { lat: parseFloat(center[0]), lng: parseFloat(center[1]) };
    var image = markerPath(container.data('marker-type'));
    var map = new google.maps.Map(el, {
      zoom: 8,
      center: location
    });
    var marker = new google.maps.Marker({
      position: location,
      map: map,
      icon: image
    });

    $(el).data('map', map).data('marker', marker);
  });
}

function crewsUri(ctx) {
  var medical = ctx.find('.crew-medical').is(':checked');
  var minCapacity = ctx.find('.crew-min-capacity').val() || '0';
  return '/cad/crews.json?medical=' + medical + '&min_capacity=' + minCapacity;
}
