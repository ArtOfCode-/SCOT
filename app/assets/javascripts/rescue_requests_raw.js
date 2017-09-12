function moveToSecondStage(lat, long) {
  $.post(location.pathname, {"lat": lat, "long": long}, function(data) {
    $('input[name=request_id]').val(data['id']);
  });
  $.get("https://maps.googleapis.com/maps/api/geocode/json?latlng=" + lat + "," + long, function(data) {
    var a = data.results[0].address_components;
    $("#street-address").val(a[0].short_name + " " + a[1].short_name);
    $("#city").val(a[4].long_name ? a[4].long_name : '');
    // $("#zip-code").val(a[8].long_name ? a[8].long_name : '');
    $('article:not(#stage2)').hide();
    $('article#stage2').show();
  });
}

function firstStep() {
  $('article:not(#stage1)').hide();
  $('article#stage1').show();
}

function longFields() {
  $('article:not(#stage3)').hide();
  $('article#stage3').show();
}

window.onload = function() {
  $('article:not(#stage1)').hide();

  $('.js-form').submit(function() {
    var valuesToSubmit = $(this).serialize();
    $.ajax({
        type: "POST",
        url: $(this).attr('action'), //sumbits it to the given url of the form
        data: valuesToSubmit,
        dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
    }).done(function(json){
        console.log("success", json);
        if (json.hasOwnProperty('location') && json['location']) {
          location.href = json['location'];
        }
    });
    return false; // prevents normal behaviour
  });

  var geoSuccess = function(position) {
    var lat = position.coords.latitude;
    var long = position.coords.longitude;
    console.log('POST ', lat, long);
    moveToSecondStage(lat, long);
  };

  var locationTrigger = document.getElementById('use-my-location');
  if (locationTrigger) {
    locationTrigger.addEventListener('click', function(evt) {
      console.log('Location request (user-initiated)');
      evt.preventDefault();
      navigator.geolocation.getCurrentPosition(geoSuccess);
    });
  }
};

function initMap() {
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 6,
    center: {lat: 29.5909775, lng: -93.9997136} // america
  });

  var input = document.getElementById('autocomplete');
  var autocomplete = new google.maps.places.Autocomplete(input);
  autocomplete.addListener('place_changed', function() {
    var place = autocomplete.getPlace().geometry.location;
    var lat = place.lat();
    var long = place.lng();
    console.log('POST ', lat, long);
    moveToSecondStage(lat, long);
  });

  google.maps.event.addListener(map, 'click', function(event) {
    var lat = event.latLng.lat();
    var long = event.latLng.lng();
    console.log('POST ', lat, long);
    moveToSecondStage(lat, long);
  });
}

$(document).on('turbolinks:load', function() {
  $("#disaster").on('change', function() {
    if ($(this).val()) {
      location.href = location.protocol + '//' + location.host + '/disasters/' + $(this).val() + '/requests/new';
    }
  });
});
