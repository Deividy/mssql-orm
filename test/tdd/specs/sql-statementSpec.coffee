SqlStatement = require('../../../lib/sql-statement')

describe('SqlStatement tests', ->
    it('should transform a json into where clause', () ->
        sql = new SqlStatement()
        sql.where([ { 'age': { '$between': [20, 49]}}, { '$and': { id: 1, login: ['deividy', 'teste', 123]} }, { 'age': 20 } ])

        expect(sql.getWhere()).toEqual("where ((age BETWEEN '20' AND '49')) AND ((id = '1') AND ((login = 'deividy') OR (login = 'teste') OR (login = '123'))) OR ((age = '20'))")
    )
)