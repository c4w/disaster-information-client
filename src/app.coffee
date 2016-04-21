endpointBase = "http://api.c4w.jp/api/v1/"
getEndpoint = (key) -> "#{endpointBase}#{key}.json"

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
        $translateProvider.preferredLanguage 'ja'
        $translateProvider.fallbackLanguage 'ja'
]


app.run [
    'acquireLocales'
    'acquireEntries'
    '$rootScope'
    (acquireLocales, acquireEntries, $rootScope) ->
        # setting
        $rootScope.languageLabel = {
            ja: '日本語'
            en: 'English'
        }
        $rootScope.err = false

        acquireLocales()
            .then (locales) ->
                $rootScope.locales = locales
                $rootScope.selectedLocale = locales[0]
                $rootScope.entries = []
                return locales

            .then (locales) ->
                acquireEntries(locales)

            .then (entries) ->
                $rootScope.entries = []
                # sort and flatten
                desc = (a, b) -> Date.parse(b.date) - Date.parse(a.date)
                entries
                    .sort desc
                    .forEach (obj)->
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
                                entry.locale = locale
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
            '$scope'
            '$rootScope'
            '$translate'
            ($scope, $rootScope, $translate) ->

                changeLanguage = (key) ->
                    $translate.use(key)
                    $rootScope.selectedLocale = key
                    $rootScope.entriesShim = $rootScope.entries.filter (entry) ->
                        entry.locale = key

                $rootScope.$on 'entriesLoaded', ->
                    $scope.key = $rootScope.selectedLocale
                    changeLanguage $scope.key

                $scope.changeLanguage = changeLanguage
        ]
    }
