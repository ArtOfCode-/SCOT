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
  $('#dispatch_request_lat').val(lat);
  $('#dispatch_request_long').val(lng);
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
