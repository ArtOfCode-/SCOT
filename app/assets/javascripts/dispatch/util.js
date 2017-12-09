function markerPath(name) {
  return $("a[data-name=" + name + "]").attr('href');
}