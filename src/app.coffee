endpointBase = "http://api.c4w.jp/api/v1/"

app = angular.module 'disaster-information-client', [
    'pascalprecht.translate'
    #'ngSanitize'
]


app.config [
    '$translateProvider'
    ($translateProvider) ->

        $translateProvider.useStaticFilesLoader {
            prefix: 'language/'
            suffix: '.json'
        }
        $translateProvider.useSanitizeValueStrategy null
        $translateProvider.preferredLanguage 'ja'
        $translateProvider.fallbackLanguage 'ja'
]


app.run [
    '$http'
    '$rootScope'
    ($http, $rootScope) ->
        getEndpoint = (key) -> "#{endpointBase}#{key}.json"
        # method = 'GET'
        # url = getEndpoint('locale')
        # $http { method, url }
        #     .then (res) ->
        #         locales = res.data
        #
        #         $rootScope.locales = locales
        locales = ['ja', 'en'] # [mocks] locale should be obtained by ajax
        $rootScope.locales = locales
        $rootScope.selectedLocale = locales[0]

        $rootScope.languageLabel = {
            ja: '日本語'
            en: 'English'
        }

        $rootScope.entries = []

        promises = []

        locales.forEach (locale) ->

            promises.push ->
                $http { Method: 'GET', url: getEndpoint locale } #[bugs] need to do this with Promise.all and emit 'loaded' event
                    .then ({data}) ->

                        desc = (a, b) -> Date.parse(b.date) - Date.parse(a.date)
                        data.entries
                            .sort desc
                            .forEach (entry) ->
                                rawDate = Date.parse(entry.date);
                                entry.date = new Date(rawDate).toLocaleDateString()
                                entry.time = new Date(rawDate).toLocaleTimeString()
                                entry.body = entry.body # need sanitization?
                                entry.locale = locale
                                $rootScope.entries.push data.entries
                        # .shim always refer selected locale
                        if locale is $rootScope.selectedLocale
                            $rootScope.entries.shim = $rootScope.entries.filter (entry) ->
                                entry.locale = locale

        Promise.all promises
            .then ->
                $rootScope.
]


app.service 'route', [
    '$location'
    '$rootScope'
    ($location, $rootScope) ->
        $rootScope.$watch ->
            $location.path()
        , (aa) ->
            alert $location.path()
            alert aa


        return {
            getRoutedEntry: ->
                result = false
                $rootScope.locales.forEach (locale) ->
                    $rootScope.entries[locale].forEach (entry) ->
                        if entry.url is $location.path() then result = entry
                return result
        }
]


app.directive 'entryArchive', ->
    return {
        restrict: 'E'
        transclude: true
        replace: true
        templateUrl: 'templates/entry-archive.html'
        controller: [
            'route'
            '$scope'
            (route, $scope) ->
                $scope.select = (entry) ->
                    $scope.$emit 'entrySelected', {entry}
                $scope.select(route.getRoutedEntry())
        ]
    }


app.directive 'singleEntry', ->
    return {
        restrict: 'E'
        transclude: true
        replace: true
        templateUrl: 'templates/single-entry.html'
        controller: [
            '$scope'
            '$rootScope'
            ($scope, $rootScope) ->
                $rootScope.$on 'entrySelected', (event, {entry}) ->
                    $scope.entry = entry
        ]
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
                $scope.key = $rootScope.selectedLocale
                $scope.changeLanguage = (key) ->
                    $translate.use(key)
                    $rootScope.selectedLocale = key
                    $rootScope.entries.shim = $rootScope.entries.filter (entry) ->
                        entry.locale = key
        ]
    }
