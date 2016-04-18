ENDPOINT         = 'http://api.c4w.jp/api/v1/pages.json'
LANG_KEY_DEFAULT = 'ja'
app = angular.module 'disaster-information-client', ['pascalprecht.translate']

app.config [
    '$translateProvider'
    ($translateProvider) ->
        $translateProvider.useStaticFilesLoader {
            prefix: 'language/lang-'
            suffix: '.json'
        }
        $translateProvider.useSanitizeValueStrategy null
        $translateProvider.preferredLanguage LANG_KEY_DEFAULT
        $translateProvider.fallbackLanguage 'en'
]


app.directive 'entryArchive', ->
    return {
        restrict: 'E'
        transclude: true
        replace: true
        templateUrl: 'templates/entry-archive.html'
    }



app.controller 'consoleCtrl', [
    '$scope'
    '$translate'
    ($scope, $translate) ->
        $scope.key = LANG_KEY_DEFAULT;
        $scope.changeLanguage = (key) -> $translate.use(key)
]


app.controller 'contentCtrl', [
    '$http'
    '$translate'
    '$scope'
    ($http, $translate, $scope) ->
        $http { Method: 'GET', url: ENDPOINT }
            .then ({data}) ->
                $scope.err = false
                dateDescOrder = (a, b) -> Date.parse(b.date) - Date.parse(a.date)

                data.entries
                    .sort dateDescOrder
                    .forEach (entry) ->
                        rawDate = Date.parse(entry.date);
                        entry.date = new Date(rawDate).toLocaleDateString()
                        entry.time = new Date(rawDate).toLocaleTimeString()
                $scope.entries = data.entries

            .catch (err) -> $scope.err = true
]
