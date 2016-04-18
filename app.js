var ENDPOINT = 'http://api.c4w.jp/api/v1/pages.json';

var app = angular.module('bss', ['pascalprecht.translate']);

app.config([
    '$translateProvider',
    function($translateProvider){

        $translateProvider.useStaticFilesLoader({
            prefix: 'assets/language/lang-',
            suffix: '.json'
        });

        $translateProvider.useSanitizeValueStrategy(null);
        $translateProvider.preferredLanguage('ja');
    }
]);


app.controller('consoleCtrl', [
    '$scope',
    '$translate',
    function($scope, $translate){
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

            // 日付の処理
            dateDescOrder = function(entryA, entryB){
                return Date.parse(entryB.date) - Date.parse(entryA.date);
            };
            res.data.entries
                .sort(dateDescOrder)
                .forEach(function(entry){
                    rawDate = Date.parse(entry.date);
                    delta_msec = Date.parse(Date()) - rawDate;

                    if (delta_msec < 1000) {//今
                        dateTimeDiff = '今';
                    } else if (delta_msec < 1000 * 60) {//x秒前
                        dateTimeDiff = parseInt(delta_msec / 1000) + $translate('SEC_LATER');
                    } else if (delta_msec < 1000 * 60 * 60) {
                        //x分前
                        dateTimeDiff = parseInt(delta_msec / (1000 * 60)) + '分前';
                    } else if (delta_msec < 1000 * 60 * 60 * 24) {
                        //x時間前
                        dateTimeDiff = parseInt(delta_msec / (1000 * 60 * 60)) + $translate('AFTER_POST.HOUR');
                    } else {
                        //x日前
                        dateTimeDiff = parseInt(delta_msec / (1000 * 60 * 60 * 60)) + '日前';
                    }

                    console.log($translate('AFTER_POST.HOUR'));
                    entry.date = new Date(rawDate).toLocaleDateString();
                    entry.time = new Date(rawDate).toLocaleTimeString();
                    entry.dateTimeDiff = dateTimeDiff;
                });

            $scope.entries = res.data.entries;

        }).catch(function(err){
            $scope.err = true;
        });

    }
]);
