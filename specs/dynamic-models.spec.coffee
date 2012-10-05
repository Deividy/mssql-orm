fs = require('fs')
DynamicModels = require("../src/dynamic-models")
Database = require('../src/database')

env = "development"
config = null
database = null
dnm = null
db = null

describe('DynamicModels: On the test', () ->
    before(() ->
        data = JSON.parse(fs.readFileSync("../config.json", "utf-8"))
        config = data[env].database.mssql
    )

    describe('for the dynamic model manipulation', () ->
        it('should have a configuration object', () ->
            config.should.be.a('object')
        )

        it('should instantiate the DynamicModels class correctly', () ->
            dnm = new DynamicModels(config)
            dnm.should.be.an.instanceOf(DynamicModels)
        )

        it('should instantiate the Database class correctly', () ->
            database = new Database(config)
            database.should.be.an.instanceOf(Database)
        )

        it('should generate the models correctly', (done) ->
            dnm.makeModels({database: database}, (m) ->
                db = m
                db.should.be.a('object')
                done()
            )
        )

        it('should create an user', (done) ->
            db.Users.insertOne({ login: 'test', pass: 123 }, {
                    success: (dn) ->
                        dn.should.be.ok
                        done()
                    error: (err) ->
                        throw new Error(err)
                        done()
                }
            )
        )

        it('should get users', (done) ->
            db.Users.findMany({
                    success: (rows) ->
                        rows.length.should.be.above(0)
                        done()
                }
            )
        )
    )
)