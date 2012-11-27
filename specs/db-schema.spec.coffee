fs = require('fs')
h = require('./test-helper')

testDb = null

newSchema = () ->
    metaData = {
        tableNames: ['Customers', 'Orders']
        columns: [
            { tableName: 'Customers', name: 'Id', position: 1 }
            { tableName: 'Customers', name: 'FirstName', position: 2 }
        ]
    }

describe('Database loadSchema()', () ->
    before((done) ->
        h.newDb((freshDb) ->
            testDb = freshDb

            testDb.utils.buildFullSchema( (err, s) ->
                throw new Error(err) if err
                testDb.loadSchema(s)

                done()
            )
        )
    )

    it('Loads schema correctly', () ->
        testDb.tables.length.should.eql(4)
    )

    it('Detects clashes in column positions', ->
        h.newDb((freshDb) ->
            s = newSchema()
            s.columns[1].position = 1
            (() -> freshDb.loadSchema(s)).should.throw(/Expected position/)
        )
    )
)
