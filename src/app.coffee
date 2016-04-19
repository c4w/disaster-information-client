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
]

# mainCtrlの中にないといけない
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
        controller:[
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



app.controller 'mainCtrl', [
    '$http'
    '$translate'
    '$scope'
    ($http, $translate, $scope) ->
        $http { Method: 'GET', url: getEndpoint 'ja' }
            .then ({data}) ->
                $scope.err = false
                desc = (a, b) -> Date.parse(b.date) - Date.parse(a.date)

                data.entries
                    .sort desc
                    .forEach (entry) ->
                        rawDate = Date.parse(entry.date);
                        entry.date = new Date(rawDate).toLocaleDateString()
                        entry.time = new Date(rawDate).toLocaleTimeString()
                        entry.body = entry.body # htmlがエスケープされるので、所定の処理が必要
                $scope.entries = data.entries
            .catch (err) -> $scope.err = true
]
