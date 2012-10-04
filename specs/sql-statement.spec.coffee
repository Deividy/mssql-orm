SqlStatement = require('../src/sql-statement')

describe('SqlStatement tests', () ->


    it('should return a select sql', () ->
        sql = new SqlStatement('users')
        sql.where({ id: 1 })
        sql.select().should.eql("SELECT * FROM users where id = 1")
    )

)