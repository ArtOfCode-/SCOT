$(document).ready(function () {
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
});

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
    console.log('place.autocomplete', lat, long);
    moveToSecondStage(lat, long);
  });

  google.maps.event.addListener(map, 'click', function (event) {
    var lat = event.latLng.lat();
    var long = event.latLng.lng();
    console.log('map.click', lat, long);
    moveToSecondStage(lat, long);
  });
}

function initShowMap() {
  var mapContainer = $('#map');
  var center = mapContainer.data('center').split(',');
  var markerType = mapContainer.data('marker-type');
  var image = markerPath(markerType);
  console.log(image);
  var location = { lat: parseFloat(center[0], 10), lng: parseFloat(center[1], 10) };
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
    var location = { lat: parseFloat(center[0], 10), lng: parseFloat(center[1], 10) };
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
  });
}

function crewsUri(ctx) {
  console.log(ctx, ctx.find('.crew-medical'));
  var medical = ctx.find('.crew-medical').is(':checked');
  var minCapacity = ctx.find('.crew-min-capacity').val() || '0';
  return '/cad/crews.json?medical=' + medical + '&min_capacity=' + minCapacity;
}
