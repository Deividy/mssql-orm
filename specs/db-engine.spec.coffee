fs = require('fs')
tds = require('tds')
DatabaseEngine = require('../src/db-engine')

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
            engine.connect({master:true}, (conn) ->
                conn.should.be.ok
                done()
            )
        )

        it('should check if the app database exists', (done) ->
            engine.execute(
                {
                    master:true
                    stmt:"SELECT DB_ID('#{config.database}');"
                    onRow: (row) ->
                        row.getValue(0).should.be.ok
                        done()
                }
            )
        )

        it('should create a database', (done) ->
            db_name = "test_db_#{Date.now()}"
            engine.execute(
                {
                    master:true
                    stmt:"IF (DB_ID('#{db_name}') IS NULL) CREATE DATABASE #{db_name};"
                    onDone: (dn) ->
                        done()
                }
            )
        )

        it('should drop the created database', (done) ->
            killDatabase = () ->
                engine.execute(
                    {
                        master:true
                        stmt:"IF (DB_ID('#{db_name}') IS NOT NULL) DROP DATABASE #{db_name};"
                        onDone: (dn) ->
                            done()
                    }
                )
            killProcess = (id) ->
                engine.execute(
                    {
                        master:true
                        stmt:"KILL #{id}"
                        onDone: (dn) ->
                            killDatabase()
                    }
                )
            engine.execute(
                {
                    master:true
                    stmt:"SELECT SPId FROM MASTER..SysProcesses WHERE DBId =
                    DB_ID('#{db_name}') AND cmd <> 'CHECKPOINT';"
                    onRow: (row) ->
                        return killProcess(row.getValue(0)) if row
                    onDone: (dn) ->
                        killDatabase()
                }
            )
        )
    )
)