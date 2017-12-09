function initResourceMaps() {
  $('.resource-map').each(function (i, el) {
    var center = $(el).data('center').split(',');
    var location = { lat: parseFloat(center[0]), lng: parseFloat(center[1]) };
    var image = markerPath('success');

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

function initResourceFormMap() {
  $('.new-resource-map').each(function (i, el) {
    var center = $(el).data('center');
    center = center ? center.split(',') : null;
    var location, zoom;
    if (center) {
      location = { lat: parseFloat(center[0]), lng: parseFloat(center[1]) };
      zoom = 8;
    }
    else {
      location = { lat: 0, lng: 0 };
      zoom = 1;
    }

    var image = markerPath('success');

    var map = new google.maps.Map(el, {
      zoom: zoom,
      center: location
    });

    if (zoom > 1) {
      var marker = new google.maps.Marker({
        position: location,
        map: map,
        icon: image
      });

      $(el).data('marker', marker);
    }

    google.maps.event.addListener(map, 'click', function (ev) {
      $('#dispatch_resource_lat').val(ev.latLng.lat());
      $('#dispatch_resource_long').val(ev.latLng.lng());

      var marker = $(el).data('marker');

      if (marker) {
        marker.setPosition(ev.latLng);
      }
      else {
        var image = markerPath('success');
        marker = new google.maps.Marker({
          position: ev.latLng,
          map: $(el).data('map'),
          icon: image
        });
        $(el).data('marker', marker);
      }
    });

    $(el).data('map', map);
  });
}

function initShowResourceMap() {
  $('.show-resource-map').each(function (i, el) {
    var center = $(el).data('center').split(',');
    var location = { lat: parseFloat(center[0]), lng: parseFloat(center[1]) };
    var image = markerPath('success');

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
