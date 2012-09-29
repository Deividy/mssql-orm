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

	getValues: (wc) -> # NO! It isnt a toilet! z)
		self = @
		if _.isArray(wc)
			console.log("ARRAY")
			console.log(wc)

			if (operators.ARRAY.type is 'link')
				link = operators.ARRAY.stmt

			console.log(link)

			for v in wc
				if (_.isString(v))
					if (v.substring(0,1) is '$')
						console.log("OPERATOR #{v}")
						console.log(operators[v])

				else
					self.getValues(v)

		else if _.isObject(wc)
			console.log("OBJECT")
			console.log(wc)
			if (operators.OBJECT.type is 'link')
				link = operators.OBJECT.stmt
				
			console.log(link)

			for v of wc

				if (_.isString(v))
					if (v.substring(0,1) is '$')
						console.log("OPERATOR #{v}")
						console.log(operators[v])

				else if (_.isObject(wc[v]) or _.isObject(wc[v]))
					console.log(wc[v])
					self.getValues(wc[v])

				else
					console.error("OTHER #{wc[v]}")
		else
			console.error("OTHER wc")

	build: ->
		self = @
		wc = @whereClause 
		@getValues(@whereClause)

sql = new SqlExpression('users')
sql.where({ login: [ 'deividy', 'deeividy', 'itsme!'] })
sql.where([ { id: 1, login: 'de' }])
sql.where({ age: { $gt: 20, $lt: 30 } })
sql.where({ $or: { name: 'Zachetti', login: "tet" } })
sql.where([ $and: { name: 'Deividy Metheler Zachetti'} ])

sql.build()