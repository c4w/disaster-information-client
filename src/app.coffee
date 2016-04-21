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
    (acquireLocales,acquireEntries, $rootScope) ->
        promise = acquireLocales()
        promise.then (data) ->
            console.log acquireEntries
        # $rootScope.err = false
        #
        # deferred = $q.defer()
        #
        #
        #
        #
        # Promise.resolve()
        #     .then (locales)->
        #         Promise.all locales.map (locale) ->
        #             new Promise (fulfilled, rejected) ->
        #                 $http.get(getEndpoint locale)
        #                     .then (res) ->
        #                         desc = (a, b) -> Date.parse(b.date) - Date.parse(a.date)
        #                         data.entries
        #                             .sort desc
        #                             .forEach (entry) ->
        #                                 rawDate = Date.parse(entry.date);
        #                                 entry.date = new Date(rawDate).toLocaleDateString()
        #                                 entry.time = new Date(rawDate).toLocaleTimeString()
        #                                 entry.body = entry.body # need sanitization?
        #                                 entry.locale = locale
        #                                 $rootScope.entries.push data.entries
        #                         # .shim always refer selected locale
        #                         if locale is $rootScope.selectedLocale
        #                             $rootScope.entries.shim = $rootScope.entries.filter (entry) ->
        #                                 entry.locale = locale
        #                         fulfilled()
        #
]

app.service 'acquireLocales', [
    '$http'
    '$q'
    '$rootScope'
    ($http, $q, $rootScope) ->
        deferred = $q.defer() # make defer instance
        return ->
            $http.get getEndpoint 'locale'
                .then (res) ->
                    # initialization
                    locales = res.data
                    $rootScope.locales = locales
                    $rootScope.selectedLocale = locales[0]
                    $rootScope.languageLabel = {
                        ja: '日本語'
                        en: 'English'
                    }
                    $rootScope.entries = []
                    deferred.resolve locales
                    return deferred.promise
                , (res) ->
                    $rootScope.err = true
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
            console.log $location.path()
            console.log aa


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
