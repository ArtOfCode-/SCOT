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

$(document).ready(function() {
  $('.slide-body').hide();

  $('.slide-header').on('click', function() {
    $(this).siblings('.slide-body').slideToggle(250);
  });

  $('.select2').select2({
    theme: 'bootstrap'
  });

  new Pikaday({
    field: $('.datepicker')[0],
    showTime: true,
    showSeconds: false,
    use24hour: true,
    defaultDate: new Date(),
    setDefaultDate: true,
    toString: function (date, format) {
      return date.toISOString();
    }
  });
});
