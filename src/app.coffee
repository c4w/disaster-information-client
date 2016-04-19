getEndpoint = (key) -> "http://api.c4w.jp/api/v1/#{key}.json"

app = angular.module 'disaster-information-client', [
    'pascalprecht.translate'
    'ngSanitize'
]

app.config [
    '$translateProvider'
    ($translateProvider) ->

        $translateProvider.useStaticFilesLoader {
            prefix: 'language/lang-'
            suffix: '.json'
        }
        #$translateProvider.useSanitizeValueStrategy null
        $translateProvider.preferredLanguage 'ja'
        $translateProvider.fallbackLanguage 'ja'
]

app.run [
    '$http'
    '$rootScope'
    ($http, $rootScope) ->
        # method = 'GET'
        # url = getEndpoint('locale')
        # $http { method, url }
        #     .then (res) ->
        #         locales = res.data
        #
        #         $rootScope.locales = locales

        # ロケール一覧を取得してくる仕組みは未実装
        $rootScope.locales = ['ja', 'en']
        $rootScope.languageLabel = {
            ja: '日本語'
            en: 'English'
        }

        $http { Method: 'GET', url: getEndpoint 'ja' }
            .then ({data}) ->
                $rootScope.error = false
                desc = (a, b) -> Date.parse(b.date) - Date.parse(a.date)

                data.entries
                    .sort desc
                    .forEach (entry) ->
                        rawDate = Date.parse(entry.date);
                        entry.date = new Date(rawDate).toLocaleDateString()
                        entry.time = new Date(rawDate).toLocaleTimeString()
                        entry.body = entry.body # htmlがエスケープされるので、所定の処理が必要
                $rootScope.entries = data.entries
            .catch (err) ->
                $rootScope.error = true
]

app.directive 'entryArchive', ->
    return {
        restrict: 'E'
        transclude: true
        replace: true
        templateUrl: 'templates/entry-archive.html'
    }


app.directive 'languageSwitch', ->
    return {
        restrict: 'E'
        transclude: true
        replace: true
        templateUrl: 'templates/language-switch.html'
        controller: [
            '$scope'
            '$rootScope'
            '$translate'
            ($scope, $rootScope, $translate) ->
                $scope.key = $scope.locales[0]
                $scope.changeLanguage = (key) ->
                    $translate.use(key)
                    $rootScope.selectedLocale = key
        ]
    }



app.directive 'errorWindow', ->
    return {
        restrict: 'E'
        replace: true
        templateUrl: 'templates/error-window.html'
    }


app.directive 'entrySingle', ->
    return {
        restrict: 'E'
        transclude: true
        replace: true
        templateUrl: 'templates/entry-single.html'

        link: (scope, element, attr) ->
            id = attr.id
            scope.entry = {
                title: id
            }
    }

app.controller 'headCtrl', [
    '$scope'
    ($scope) ->
        $scope.entrySelected = (entry) ->
            $scope.$emit 'entrySelected', {entry}
]



app.controller 'mainCtrl', [
    '$scope'
    '$rootScope'
    ($scope, $rootScope) ->
        $rootScope.$on 'entrySelected', (event, {entry}) ->
            $scope.entry = entry
]
