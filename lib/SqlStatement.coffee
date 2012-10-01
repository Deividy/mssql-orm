SqlExpression = require('./SqlExpression')
_ = require('underscore')

class SqlStatement
	constructor: (@tableSchema) ->
		@whereClause = []
		@columns = []

	save: ->


	select: (w) ->
		where = @getWhere(w)
		columns = @getColumns()

		return "SELECT #{columns} FROM .. #{where}"

	insert: (data) ->
		
	update: (data, w) ->
		where = @getWhere(w)
		
	column: (c) ->
		if (_.isArray(c))
			for cl in c
				@columns.push(cl)
		else
			@columns.push(c)

	where: (w) ->
		@whereClause.push(w)

	getColumns: ->
		columns = ''
		if (@columns.length >= 1)
			count = 1
			for c in @columns
				if (count > 1) then columns += ", "
				columns += c
				count++
		else
			columns = "*"

		return columns

	getWhere: (w) ->
		s = new SqlExpression()
		if (w) 
			v = s.build(w)
		else
			v = s.build(@whereClause)
		
		if (v)
			return "where #{v}"
		else
			return ""

sql = new SqlStatement()
sql.where({ login: [ 'deividy', 'deeividy', 'itsme!'], pass: '123' })
sql.where([ { id: 1, login: 'de' }])
sql.where({ age: { $gt: 20, $lt: 30 } })
sql.where({ $or: { name: 'Zachetti', login: "tet" } })
sql.where({ name: 'Deividy Metheler Zachetti'} )

console.log sql.select()



