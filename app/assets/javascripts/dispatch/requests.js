$(document).ready(function () {
  $(document).on('shown.bs.modal', function (ev) {
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
      var problems = requiredInputs.filter(function (el) { return !$(el).val(); });
      problems.each(function (i, el) {
        console.log(el);
        $(el).addClass('is-invalid');
      });
      var firstProblem = $(problems[0]);
      var problemSection = firstProblem.parents('.section.collapse').first();
      problemSection.collapse('show');
      scot.scrollToAnchor('#' + firstProblem.attr('id'));
    }
  });
});

function moveToSecondStage(lat, lng) {
  $('input[name=lat]').val(lat);
  $('input[name=long]').val(lng);
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
