_ = require('underscore')
fs = require('fs')

operators = JSON.parse(fs.readFileSync("./operators.json", "utf-8"))

class SqlExpression
	# SqlExpression knows only the table name
	constructor: (@table) ->
		@whereClause = []

	where: (w) ->
		@whereClause.push(w)
	
	order: (o) ->

	limit: (l) ->

	getWhere: ->
		return @whereClause
	
	getValues: (whereClause, whereKeys, whereValues) ->
		self = @
		if (_.isArray(whereClause))
			if (operators.ARRAY.type is 'link')
				link = operators.ARRAY.stmt

			for v in whereClause
				if (_.isString(v))
					if (v.substring(0,1) is '$')
						where+=v

				else
					self.getValues(v)

		else if (_.isObject(whereClause))
			if (operators.OBJECT.type is 'link')
				link = operators.OBJECT.stmt
			
			for v of whereClause

				if (_.isString(v))
					if (v.substring(0,1) is '$')
						w=v

				else if (_.isObject(whereClause[v]) or _.isObject(wc[v]))
					self.getValues(whereClause[v])

				else
					console.error("OTHER #{whereClause[v]}")
		else
			console.error("OTHER #{whereClause}")

	build: ->
		self = @
		wc = @whereClause
		console.log(@whereClause) 
		@getValues(@whereClause)

###
[ 
	{ login: [ 'deividy', 'deeividy', 'itsme!' ] },
	[ { id: 1, login: 'de' } ],
	{ age: { '$gt': 20, '$lt': 30 } },
	{ '$or': { name: 'Zachetti', login: 'tet' } },
	{ name: 'Deividy Metheler Zachetti' } 
]

AND (login = 'deividy' OR login = 'deeividy' OR login = 'itsme!') 
OR ( id = 1 AND login = 'de')
AND (age > 20 AND age < 30)
OR ( name = 'Zachetti' AND login = 'tet' )
and ( name = 'Deividy Metheler Zachetti' )

###

sql = new SqlExpression('users')
sql.where({ login: [ 'deividy', 'deeividy', 'itsme!'] })
sql.where([ { id: 1, login: 'de' }])
sql.where({ age: { $gt: 20, $lt: 30 } })
sql.where({ $or: { name: 'Zachetti', login: "tet" } })
sql.where({ name: 'Deividy Metheler Zachetti'} )

sql.build()



