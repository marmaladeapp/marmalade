//= require jquery
// require jquery.turbolinks
//= require jquery_ujs
//
//= require fastclick
//
//= require foundation-apps
//= require_tree ../../../vendor/assets/javascripts/services/.
//= require_tree ../../../vendor/assets/javascripts/components/.
//
// require turbolinks

//Turbolinks.enableProgressBar();

//angular.module('modalMarmalade', ['ui.router','ngAnimate','foundation','foundation.dynamicRouting','foundation.dynamicRouting.animations']);

(function() {
  'use strict';

  angular.module('application', ['ui.router','ngAnimate','foundation','foundation.dynamicRouting','foundation.dynamicRouting.animations']).config(config).run(run);

  config.$inject = ['$urlRouterProvider', '$locationProvider'];

  function config($urlProvider, $locationProvider) {
    $urlProvider.otherwise('/');

    $locationProvider.html5Mode({
      enabled: false,
      requireBase: false
    });

    $locationProvider.hashPrefix('!');
  }
  

  function run() {
    FastClick.attach(document.body);
  }
    
})();


$(document).ready(function(){
  //angular.bootstrap($("#modalMarmalade"), ['modalMarmalade'])
})
$(document).on('page:load', function(){
  //angular.bootstrap($("#modalMarmalade"), ['modalMarmalade'])
})



//#pantherCurrency{"ng-controller" => "CurrencyConverter"}

