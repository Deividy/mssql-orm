fs = require('fs')
tds = require('tds')
h = require('./test-helper')
DatabaseEngine = h.requireSrc('db-engine')

env = "development"
config = h.defaultDbConfig
engine = null
db_name = null

describe('DatabaseEngine: On the test', () ->
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

        it('says the app database exists', (done) ->
            engine.adapter.doesDatabaseExist(config.database, (db) ->
                db.should.be.true
                done()
            )
        )

        it('says an inexistent db does not exist', (done) ->
            engine.adapter.doesDatabaseExist('Random3490', (db) ->
                db.should.be.false
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
