ENDPOINT_BASE = "http://api.c4w.jp/api/v1/"
DEFAULT_LANG = 'ja'
FALLBACK_LANG = 'en'
LANGUAGE_LABELS =
    ja: '日本語'
    en: 'English'

getEndpoint = (key) -> "#{ENDPOINT_BASE}#{key}.json"

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
        $translateProvider.useSanitizeValueStrategy null
        $translateProvider.preferredLanguage DEFAULT_LANG
        $translateProvider.fallbackLanguage FALLBACK_LANG
]


app.run [
    'acquireLocales'
    'acquireEntries'
    '$rootScope'
    (acquireLocales, acquireEntries, $rootScope) ->
        # setting
        $rootScope.languageLabel = LANGUAGE_LABELS
        $rootScope.err = false

        acquireLocales()
            .then (locales) ->
                $rootScope.locales = locales
                $rootScope.selectedLocale = DEFAULT_LANG
                $rootScope.entries = []
                return locales

            .then (locales) ->
                acquireEntries(locales)

            .then (entries) ->
                $rootScope.entries = []
                console.log entries
                # sort and flatten
                entries
                    .sort (a, b) ->
                        date = (x) ->
                            Date.parse x.date
                        return date b - date a
                    .forEach (obj) ->
                        obj.forEach (entry) ->
                            $rootScope.entries.push entry

            .then ->
                $rootScope.$emit 'entriesLoaded'

            .catch (res) ->
                console.log res
                $rootScope.err = true

]


app.service 'acquireLocales', [
    '$http'
    '$q'
    ($http, $q) ->
        deferred = $q.defer() # make defer instance
        return ->
            $http.get getEndpoint 'locale'
                .then (res) ->
                    # initialization
                    locales = res.data
                    deferred.resolve locales
                    return deferred.promise
                , (res) ->
                    deferred.reject res
                    return deferred.promise
]


app.service 'acquireEntries', [
    '$http'
    '$q'
    ($http, $q) ->
        return (locales) ->
            $q.all locales.map (locale) ->
                deferred = $q.defer()
                $http.get getEndpoint locale
                    .then (res) ->
                        entries = res.data.entries
                        entries
                            .forEach (entry) ->
                                rawDate = Date.parse(entry.date);
                                entry.date = new Date(rawDate).toLocaleDateString()
                                entry.time = new Date(rawDate).toLocaleTimeString()
                                entry.body = entry.body # need sanitization?
                        deferred.resolve entries
                        return deferred.promise

                    , (res) ->
                        deferred.reject res
                        return deferred.promise
]


app.service 'route', [
    '$location'
    '$rootScope'
    ($location, $rootScope) ->
        $rootScope.$watch ->
            $location.path()
        , (aa) ->
            true


        # return {
        #     getRoutedEntry: ->
        #         result = false
        #         $rootScope.locales.forEach (locale) ->
        #             $rootScope.entries[locale].forEach (entry) ->
        #                 if entry.url is $location.path() then result = entry
        #         return result
        # }
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
                #$scope.select(route.getRoutedEntry())
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
            '$translate'
            '$scope'
            '$rootScope'
            ($translate, $scope, $rootScope) ->

                changeLanguage = (key) ->
                    $translate.use(key)
                    $rootScope.selectedLocale = key
                    $rootScope.entriesShim = $rootScope.entries.filter (entry) ->
                        entry.lang is key

                $rootScope.$on 'entriesLoaded', ->
                    $scope.key = $rootScope.selectedLocale
                    changeLanguage $scope.key

                $scope.changeLanguage = changeLanguage
        ]
    }
