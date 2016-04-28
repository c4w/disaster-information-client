ENDPOINT = 'http://api.c4w.jp/api/v1/pages.json'

app = module 'disaster-information-client'
beforeEach app


describe 'test of initialization', ->

    it '', ->
        console.log app
        expect true
            .toEqual true

#
# describe 'test of services', ->
#
#     describe 'test of `loadEntries` service', ->
#         loadEntries = {}
#         rootScope   = {}
#         beforeEach inject (_loadEntries_, $rootScope) ->
#             loadEntries = _loadEntries_
#             rootScope   = $rootScope
#
#
#         it 'should be thenable.', ->
#             expect loadEntries().then
#                 .toBeDefined()
#             expect loadEntries().then instanceof Function
#                 .toBe true
#
#         it 'should set entries into rootScope', (done)->
#
#             promise = new Promise (resolve, reject) ->
#                 expect
#                 resolve()
#
#             loadEntries ENDPOINT
#
#
#             promise.then (value)->
#                 console.log value
#
#                 .then.toString()
#                 .then ->
#                     done()
