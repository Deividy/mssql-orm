###
SqlStatement = require('../src/sql-statement')

describe('SqlStatement tests', () ->

    describe("Select tests", () ->
        it('should return a select sql', () ->
            sql = new SqlStatement('users')
            sql.where({ id: 1 })
            sql.select().should.eql("SELECT * FROM users where (id = 1)")
        )

        it('accepts select with columns', () ->
            sql = new SqlStatement('users')
            sel = sql.select([ 'login', 'id'], { id: 1 })
            sel.should.eql("SELECT login, id FROM users where (id = 1)")
        )

        it('accepts select with column aliases in a array', () ->
            sql = new SqlStatement('users')
            sel = sql.select([ {'zlogin': 'login' }, { 'zid': 'id' }, 'name' ], { id: 1 })
            sel.should.eql("SELECT zlogin as login, zid as id, name FROM users where (id = 1)")
        )

        it('supports a object with columns and aliases', () ->
            sql = new SqlStatement('users')
            sel = sql.select([ {'zlogin': 'login', 'zid': 'id' }, 'name' ], { id: 1 })
            sel.should.eql("SELECT zlogin as login, zid as id, name FROM users where (id = 1)")
        )

        it("supports a string for where clause", () ->
            sql = new SqlStatement('users')
            sel = sql.select([ {'zlogin': 'login', 'zid': 'id' }, 'name' ], "id = 1")
            sel.should.eql("SELECT zlogin as login, zid as id, name FROM users where id = 1")
        )
    )

    describe("Insert tests", () ->
        it('should return a insert sql', () ->
            s = new SqlStatement('users')
            i = s.insert({ name: 'Test', login: 'testing', number: 20 })
            e = "INSERT INTO users (name, login, number) VALUES ('Test', 'testing', 20)"
            i.should.eql(e)
        )
    )

    describe("Update tests", () ->
        it('should return a update sql', () ->
            s = new SqlStatement('users')
            i = s.update({ name: 'testing', login: 'test' }, { id: 1 })
            e = "UPDATE users set name = 'testing', login = 'test' where (id = 1)"
            i.should.eql(e)
        )

        it('accepts .update(object, array) should return a update sql with or clause', () ->
            s = new SqlStatement('users')
            i = s.update({ name: 'testing', login: 'test' }, [{ id: 1 }, { l: 't'}])
            e = "UPDATE users set name = 'testing', login = 'test' where ((id = 1) OR (l = 't'))"
            i.should.eql(e)
        )
    )

    describe("Delete tests", () ->
        it('should return a delete sql', () ->
            s = new SqlStatement('users')
            e = "DELETE FROM users where (id = 1)"
            s.delete({ id: 1 }).should.eql(e)
        )
    )

    describe("Chaining tests", () ->
        it('should return a select sql', () ->
            s = new SqlStatement('users')
            s.column([ 'name', { zid: 'id' }])
                .where({ id: 1 })
                .and({ login: 'test' })

            e = "SELECT name, zid as id FROM users where ((id = 1) AND (login = 'test'))"
            s.select().should.eql(e)
        )
    )
)