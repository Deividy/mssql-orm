class SqlExpression
	constructor: (@table) ->
		@whereClause = []

	where: (w) ->
		@whereClause.push(w)

	getWhere: ->
		return @whereClause

	getStmt: ->

sql = new SqlExpression('users')
sql.where({ login: [ 'deividy', 'deeividy', 'dee' ] })
sql.where([{ id: 1 }])
sql.where({ age: { $gt: 20 } })
sql.where({ $or: { id: 20 }})
sql.where({ $and: { name: 'Deividy Metheler Zachetti' }})

 
console.log sql.getWhere()
