fs = require('fs')
h = require('./test-helper')
Database = h.requireSrc('database')

env = "development"
database = null

describe('Database: On the test', () ->
    describe('for the queries', () ->
        it('should have a configuration object', () ->
            h.testConfig.databases.should.be.a('object')
        )

        it('should instantiate the Database class correctly', () ->
            database = h.getDb()
            database.should.be.an.instanceOf(Database)
        )

        it('should execute a simple query', (done) ->
            stmt = "SELECT 1"
            database.query(stmt, (data) ->
                done()
            )
        )

        it('should get query rows', (done) ->
            stmt = "SELECT 1 AS test"
            database.getRows(stmt, (data) ->
                data.should.eql([{test:1}])
                done()
            )
        )
    )
)
