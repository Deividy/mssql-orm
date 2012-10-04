fs = require('fs')
tds = require('tds')
DatabaseEngine = require('../src/db/engine')

env = "development"
config = null
engine = null
db_name = null

describe('DatabaseEngine: On the test', () ->
    before(() ->
        data = JSON.parse(fs.readFileSync("./config.json", "utf-8"))
        config = data[env].database.mssql
    )

    describe('for the database', () ->
        it('should have a configuration object', () ->
            config.should.be.a('object')
        )

        it('should connect to the master database', (done) ->
            engine = new DatabaseEngine(config)
            engine.adapter.connect({master:true}, (conn) ->
                conn.should.be.ok
                done()
            )
        )

        it('should check if the app database exists', (done) ->
            engine.adapter.doesDatabaseExist(config.database, (db) ->
                db.should.be.ok
                done()
            )
        )

        it('should create a database', (done) ->
            db_name = "test_db_#{Date.now()}"
            engine.adapter.createDatabase(db_name, (dn) ->
                done()
            )
        )

        it('should check if the created database exists', (done) ->
            engine.adapter.doesDatabaseExist(db_name, (db) ->
                db.should.be.ok
                done()
            )
        )

        it('should drop the created database', (done) ->
            engine.adapter.dropDatabase(db_name, (dn) ->
                dn.should.be.ok
                done()
            )
        )
    )
)