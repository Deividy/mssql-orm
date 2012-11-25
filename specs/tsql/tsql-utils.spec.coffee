h = require('../test-helper')
db = h.getDb('mssql')

db_utils = db.utils

describe('TsqlUtils', () ->
    it('should create a date now', (done) ->
        db_utils.dbNow((err, date) ->
            x = new Date(date)
            date.toTimeString().should.eql(x.toTimeString())
            done()
        )
    )

    it('should create a date now on utc', (done) ->
        db_utils.dbUtcNow((err, date) ->
            x = new Date(date)
            date.toTimeString().should.eql(x.toTimeString())
            done()
        )
    )

    it('should check the offset to utc', (done) ->
        db_utils.dbUtcOffset((err, offset) ->
            offset.should.a('number')
            done()
        )
    )
    )
