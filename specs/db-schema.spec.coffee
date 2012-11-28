fs = require('fs')
h = require('./test-helper')

should = require('should')
{ Table, Column } = h.requireSrc('db-objects')

testDb = null

newSchema = () ->
    metaData = {
        tables: [
            { name: 'Customers', }
            { name: 'Orders' }
        ]
        columns: [
            { tableName: 'Customers', name: 'Id', position: 1 }
            { tableName: 'Customers', name: 'FirstName', position: 2 }
        ]
        keys: []
        foreignKeys: []
        keyColumns: []
    }

withDbAndSchema = (f) -> f(h.blankDb(), newSchema())

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

    it('Detects clashes in column positions', () ->
        withDbAndSchema((db, s) ->
            s.columns[1].position = 1
            (() -> db.loadSchema(s)).should.throw(/Expected position/)
        )
    )

    it('Throws if name and alias are missing', ->
        withDbAndSchema((db, s) ->
            s.tables[0].name = null
            (() -> db.loadSchema(s)).should.throw(/must provide/)
        )
    )

    it('Allows tables with only an alias', ->
        withDbAndSchema((db, s) ->
            s.tables.push({ alias: 'FakePlasticTable' })
            db.loadSchema(s)
            db.tables.length.should.eql(3)

            t = db.tablesByAlias.FakePlasticTable
            t.should.be.an.instanceof(Table)
            should.not.exist(t.name)
            t.alias.should.eql('FakePlasticTable')

            c = new Column(t, { name: 'Id' })
            c.table.should.eql(t)
            t.columns.length.should.eql(1)
        )
    )

    it('Throws if a name clashes', ->
        clash = () -> testDb.tablesByName.Customers.alias = 'Orders'
        clash.should.throw(/it is already taken/)
    )

    it('Throws if an alias clashes', ->
        clash = () -> testDb.tablesByName.Customers.alias = 'Orders'
        clash.should.throw(/it is already taken/)
    )
)
