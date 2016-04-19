ENDPOINT = 'http://api.c4w.jp/api/v1/pages.json'


describe 'test of services', ->
    app = module 'disaster-information-client'
    beforeEach app

    describe 'test of `loadEntries` service', ->
        loadEntries = {}
        beforeEach inject (_loadEntries_) ->
            loadEntries = _loadEntries_
            # console.log loadEntries
        it 'should be thenable.', ->
            expect loadEntries().then
                .toBeDefined()
