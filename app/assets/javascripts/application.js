// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//
//= require nprogress
//= require nprogress-turbolinks
//
//= require_tree .

$(function() {
  $('.js-github-form').on('submit', function(e) {
    e.preventDefault();
    var $form = $(this);
    var username = $form.find('input[name="username"]').val();
    var name = $form.find('input[name="name"]').val();
    console.log(username, name)
    if (name.length > 0 && username.length > 0) {
      window.location = '/' + username + '/' + name;
    }
  });
});
