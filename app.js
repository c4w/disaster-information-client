var ENDPOINT = 'http://api.c4w.jp/api/v1/pages.json';
var LANG_KEY_DEFAULT = 'ja';
var app = angular.module('bss', ['pascalprecht.translate']);

app.config([
    '$translateProvider',
    function($translateProvider){
        $translateProvider.useStaticFilesLoader({
            prefix: 'assets/language/lang-',
            suffix: '.json'
        });
        $translateProvider.useSanitizeValueStrategy(null);
        $translateProvider.preferredLanguage(LANG_KEY_DEFAULT);
        $translateProvider.fallbackLanguage('en');
    }
]);


app.controller('consoleCtrl', [
    '$scope',
    '$translate',
    function($scope, $translate){
        $scope.key = LANG_KEY_DEFAULT;
        $scope.changeLanguage = function(key){
            $translate.use(key);
        }
    }
]);


app.controller('contentCtrl', [
    '$http',
    '$translate',
    '$scope',
    function($http, $translate, $scope){

        $http({
            Method: 'GET',
            url: ENDPOINT,
        }).then(function(res){
            $scope.err = false;

            dateDescOrder = function(entryA, entryB){
                return Date.parse(entryB.date) - Date.parse(entryA.date);
            };

            res.data.entries
                .sort(dateDescOrder)
                .forEach(function(entry){
                    rawDate = Date.parse(entry.date);
                    entry.date = new Date(rawDate).toLocaleDateString();
                    entry.time = new Date(rawDate).toLocaleTimeString();
                });
            $scope.entries = res.data.entries;

        }).catch(function(err){
            $scope.err = true;
        });

    }
]);
