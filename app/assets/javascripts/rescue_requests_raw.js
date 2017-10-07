function moveToSecondStage(lat, long) {
  $.post(location.pathname, {"lat": lat, "long": long}, function(data) {
    $('input[name=request_id]').val(data['id']);
    requestAccessKey = data['key'];
  });
  $.get("https://maps.googleapis.com/maps/api/geocode/json?latlng=" + lat + "," + long, function(data) {
    var a = data.results[0].address_components;
    var conv = {
      "route": "street_address",
      "street_number": "street_address",
      "locality": "city",
      "postal_code": "zip_code",
      "administrative_area_level_1": "state",
      "country": "country"
    };
    for (var i = 0; i < a.length; i++) {
      var component = a[i];
      var e = $("#"+conv[component.types[0]]);
      e.val(e.val() + (e.val() === '' ? '' : " ") + component.long_name);
      console.log(component);
      console.log(e);
    }
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

var requestAccessKey = null;

window.onload = function() {
  $('article:not(#stage1)').hide();

  $('.js-form').submit(function() {
    var arrayData = $(this).serializeArray();
    var jsonData = {};
    arrayData.forEach(function (x) {
      jsonData[x['name']] = x['value'];
    });
    var valuesToSubmit = Object.assign(jsonData, { key: requestAccessKey });
    console.log('Submitting', valuesToSubmit);
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
        if (json.hasOwnProperty('key') && json['key']) {
          requestAccessKey = json['key'];
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

$(document).ready(function() {
  $("#disaster").on('change', function() {
    if ($(this).val()) {
      location.href = location.protocol + '//' + location.host + '/disasters/' + $(this).val() + '/requests/new';
    }
  });
});
