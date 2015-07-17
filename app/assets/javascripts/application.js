// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//= require 'jquery'
//= require 'jquery.truncator'

$(document).ready(function() {
  $('.desc-content').truncate({ max_length: 550 });
});
