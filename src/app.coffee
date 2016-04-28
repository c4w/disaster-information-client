ENDPOINT_BASE = "http://api.c4w.jp/api/v1/"
RESPONSE_FORMAT = 'json'
DEFAULT_LANG = 'ja'
FALLBACK_LANG = 'en'
LANGUAGE_LABELS =
    ja: '日本語'
    en: 'English'

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
                # sort and flatten
                entries
                    .sort (a, b) ->
                        date = (x) ->
                            Date.parse x.date
                        return date b - date a
                    .forEach (obj) ->
                        obj.forEach (entry) ->
                            entry.meta = JSON.stringify entry.meta
                            $rootScope.entries.push entry

            .then ->
                $rootScope.$emit 'entriesLoaded', {status:'success'}

            .catch (res) ->
                console.log res
                $rootScope.err = true
]


app.service 'getEndpoint', [
    ->
        (key)->
            "#{ENDPOINT_BASE}#{key}.#{RESPONSE_FORMAT}"
]


app.service 'acquireLocales', [
    'getEndpoint'
    '$http'
    '$q'
    (getEndpoint, $http, $q) ->
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
    'getEndpoint'
    '$http'
    '$q'
    (getEndpoint, $http, $q) ->
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


app.service 'router', [
    '$location'
    '$rootScope'
    ($location, $rootScope) ->
        $rootScope.$on 'entriesLoaded', ->
            $rootScope.$watch ->
                $location.path()
            , (url) ->
                if url is ''
                    $rootScope.$emit 'entryUnselected'
                else
                    entry = ($rootScope.entries.filter (entry) ->
                        entry.url is url
                    )[0]
                    $rootScope.$emit 'entrySelected', {entry}
]


app.controller 'mainCtrl', [
    '$scope'
    ($scope) ->
        $scope.entry = false
        $scope.$on 'entryUnselected', (event) ->
            $scope.entry = false

]


app.directive 'entryArchive', ->
    return {
        restrict: 'E'
        transclude: true
        replace: true
        templateUrl: 'templates/entry-archive.html'
        controller: [
            'router'
            '$scope'
            (router, $scope) ->
                $scope.detag = (html) ->
                        if html? then String(html).replace(/<[^>]+>/gm, '') else ''
                $scope.select = (entry) ->
                    $scope.$emit 'entrySelected', {entry}
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
                $scope.unselect = ->
                    $scope.entry = false
                $rootScope.$on 'entrySelected', (event, {entry}) ->
                    $scope.entry = entry
                $rootScope.$on 'entryUnselected', (event) ->
                    $scope.entry = false
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
                $scope.key = DEFAULT_LANG

                changeLanguage = (key) ->
                    $translate.use(key)
                    $rootScope.selectedLocale = key
                    $rootScope.entriesShim = $rootScope.entries.filter (entry) ->
                        entry.lang is key

                $scope.changeLanguage = changeLanguage

                $rootScope.$on 'entriesLoaded', ->
                    $scope.key = $rootScope.selectedLocale
                    changeLanguage $scope.key

        ]
    }
