fs = require('fs')
Database = require('../src/database')
h = require('./test-helper')

env = "development"
config = null
database = null

describe('Database: On the test', () ->
    before(() ->
        data = JSON.parse(fs.readFileSync("./config.json", "utf-8"))
        config = data[env].database.mssql
    )

    describe('for the queries', () ->
        it('should have a configuration object', () ->
            config.should.be.a('object')
        )

        it('should instantiate the Database class correctly', () ->
            database = new Database(config)
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
