fs = require('fs')
tds = require('tds')
DatabaseUtils = require('../src/utils')

env = "development"
config = null
db_utils = null

describe('DatabaseUtils: On the test', () ->
    before(() ->
        data = JSON.parse(fs.readFileSync("./config.json", "utf-8"))
        config = data[env].database.mssql
    )

    describe('for the date utils', () ->
        it('should have a configuration object', () ->
            config.should.be.a('object')
        )

        it('should instantiate the DatabaseUtils class correctly', () ->
            db_utils = new DatabaseUtils(config)
            db_utils.should.be.an.instanceOf(DatabaseUtils)
        )

        it('should create a date now', (done) ->
            db_utils.dbNow((date) ->
                x = new Date(date)
                date.toTimeString().should.eql(x.toTimeString())
                done()
            )
        )

        it('should create a date now on utc', (done) ->
            db_utils.dbUtcNow((date) ->
                x = new Date(date)
                date.toTimeString().should.eql(x.toTimeString())
                done()
            )
        )

        it('should check the offset to utc', (done) ->
            db_utils.dbUtcOffset((offset) ->
                offset.should.a('number')
                done()
            )
        )
    )
)
