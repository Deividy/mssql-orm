SqlStatement = require('../../../lib/sql-statement')

describe('SqlStatement tests', () ->
    it('should transform a json into where clause', () ->
        sql = new SqlStatement()
        sql.where([ { 'age': { '$between': [20, 49]}}, { '$and': { id: 1, login: ['deividy', 'teste', 123]} }, { 'age': { '$egt': 20, '$elt': '30' } } ])

        expect(sql.getWhere()).toEqual("where ((age BETWEEN '20' AND '49')) AND ((id = '1') AND ((login = 'deividy') OR (login = 'teste') OR (login = '123'))) OR ((age >= '20') AND (age <= '30'))")
    )

    it('should return a where clause', () ->
        sql = new SqlStatement()
        sql.where({ login: { '$like': 'Deividy' }, id: { '$in': [1,2,3,4,5,6] }, '$or': { name: ['testing', 'testman'] } })
        sql.where({ age: { '$between': [20, 30] }, login: ['teste', 'test', 'testing...'] })
        expect(sql.getWhere()).toEqual("where  ((login LIKE '%Deividy%') AND (id IN (1,2,3,4,5,6)) OR ((name = 'testing') OR (name = 'testman'))) AND ((age BETWEEN '20' AND '30') AND ((login = 'teste') OR (login = 'test') OR (login = 'testing...')))")
    )
)