function nextStep(lat, long) {
  $.post("/requests/create", {"lat": lat, "lng": long, "disaster_id": $('#stage0 select')[0].value}, function(data) {
    $('input[name=disaster_id]').val($('#stage0 select')[0].value);
    $('input[name=person_id').val(data);
  });
  $.get("https://maps.googleapis.com/maps/api/geocode/json?latlng="+lat+","+long, function(data) {
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
  $('article:not(#stage0)').hide();

  $('form').submit(function() {  
    var valuesToSubmit = $(this).serialize();
    $.ajax({
        type: "POST",
        url: $(this).attr('action'), //sumbits it to the given url of the form
        data: valuesToSubmit,
        dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
    }).success(function(json){
        console.log("success", json);
    });
    return false; // prevents normal behaviour
  });

  var geoSuccess = function(position) {
    var lat = position.coords.latitude;
    var long = position.coords.longitude;
    console.log('POST ', lat, long);
    nextStep(lat, long);
  };

  document.getElementById('use-my-location').addEventListener('click', function(evt) {
    console.log('Location request (user-initiated)');
    evt.preventDefault();
    navigator.geolocation.getCurrentPosition(geoSuccess);
  });
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
    nextStep(lat, long);
  });

  google.maps.event.addListener(map, 'click', function(event) {
    var lat = event.latLng.lat();
    var long = event.latLng.lng();
    console.log('POST ', lat, long);
    nextStep(lat, long);
  });
}
