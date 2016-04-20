getEndpoint = (key) -> "http://api.c4w.jp/api/v1/#{key}.json"

app = angular.module 'disaster-information-client', [
    'pascalprecht.translate'
    'ngSanitize'
]

app.config [
    '$translateProvider'
    ($translateProvider) ->

        $translateProvider.useStaticFilesLoader {
            prefix: 'language/'
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
        locales = ['ja', 'en']
        $rootScope.locales = locales
        $rootScope.selectedLocale = locales[1]

        $rootScope.languageLabel = {
            ja: '日本語'
            en: 'English'
        }

        $rootScope.entries = {}
        locales.forEach (locale) ->
            $http { Method: 'GET', url: getEndpoint locale }
                .then ({data}) ->

                    desc = (a, b) -> Date.parse(b.date) - Date.parse(a.date)
                    data.entries
                        .sort desc
                        .forEach (entry) ->
                            rawDate = Date.parse(entry.date);
                            entry.date = new Date(rawDate).toLocaleDateString()
                            entry.time = new Date(rawDate).toLocaleTimeString()
                            entry.body = entry.body # need sanitization?
                    $rootScope.entries[locale] = data.entries
                    console.log locale
                    # .shim always refer selected locale
                    if locale is $rootScope.selectedLocale
                        $rootScope.entries.shim = $rootScope.entries[locale]

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
                $scope.key = $rootScope.selectedLocale
                $scope.changeLanguage = (key) ->
                    $translate.use(key)
                    $rootScope.selectedLocale = key
                    $rootScope.entries.shim = $rootScope.entries[key]
                    console.log $rootScope.entries.shim
        ]
    }



app.controller 'mainCtrl', [
    '$scope'
    ($scope) ->
        return
]
