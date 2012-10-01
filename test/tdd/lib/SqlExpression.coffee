# Link é para dizer basicamente se é and ou or, o nome link é pq ele é o que linka as clause
# op é = != > < >= <= LIKE IN

# Se algum dos valores de where for array ou object ele altera o valor de link caso seja array é 
# necessario ele conter um objeto, caso contrário kabum! Se for objeto é varrido e 
# verifica se a key é um operador, se for um operador ele usa o operador e da um replace nos 
# values, se for uma string ele concatena a query e procura o seu value se o 
# value for array ou object ele altera novamente a precedencia de link e varre esse objecto, caso
# seja array a coluna só é duplicada e jogada como OR, caso seja objeto a key é ncessário ser um 
# operador, caso não seja operador a query explode, exemplo:  age: { age: 50 } (é bem sick alguém
# fazer isso, mas se acontecer it explodes)

###
A ideia é enviar isso para alguma função do tipo buildExpression, ela fazer o replace e nos devolver 
a clause que queremos, nesse caso:
AND ( (login = 'deividy') OR (login = 'deeividy') OR (login = 'itsme!') )


		clause =  {
			link: 		'AND' 
			op: 		'='
			expression:	'$COLUMN$ $OP$ $VALUE$'			
			column: 	'login' 
			value: 		'' 
			values: 	[ 'deividy', 'deeividy', 'itsme!' ] 
		}
				
###
_ = require('underscore')
fs = require('fs')

operators = JSON.parse(fs.readFileSync("../../../lib/operators.json", "utf-8"))

module.exports = 
	buildExpression: (exp, values) ->
		exp = exp.replace("$COLUMN$", values.column)
		exp = exp.replace("$VALUE$", "'#{values.value}'")
		exp = exp.replace("$OP$", values.op)

		return exp

	setOperator: (operators, c, v) ->
		if (operators[v].type is "expression")				
			c.expression = operators[v].expression
		else if (operators[v].type is "op")
			c.op = operators[v].op
		else if (operators[v].type is "link")
			c.link = operators[v].link
		return c
	jsonToClauses: (c, json) ->
		self = @
		clause = []
		for v of json
			if (v.substring(0,1) is "$")
				c = @setOperator(operators, c, v)
			else
				c.column = v

			if (_.isArray(json[v]))	
				c.values = json[v]
			else if (_.isObject(json[v]))
				dgo = 1
				cl = c

				for val of json[v]
					cl.link = operators["OBJECT"].link
					if (!_.isString(val))
						console.error("INVALID QUERY: ", val)
					else
						if (val.substring(0,1) isnt "$")
							console.error("INVALID QUERY, VALUES ONLY CAN BE OPERATORS: ", val)
						else
							cl = self.setOperator(operators, cl, val)
					
					if (_.isArray(json[v][val]))
						cl.values = json[v][val]
					else
						cl.value = json[v][val]
						
					clause.push( 
						link: cl.link
						op: cl.op
						expression: cl.expression
						column: cl.column
						value: cl.value
						values: cl.values 
					)
			else
				c.value = json[v]
			if (!dgo)
				clause.push( 
					link: c.link
					op: c.op
					expression: c.expression
					column: c.column
					value: c.value
					values: c.values 
				)
				c.value = ''
				c.values = []
			dgo = 0
		return clause

	jsonToClause: (json, c) ->
		self = @
		clause = []
		if (!c)
			c =  {
				link: 		operators['DEFAULT'].link
				op: 		operators['DEFAULT'].op
				expression:	operators['DEFAULT'].expression			
				column: 	'' 
				value: 		'' 
				values: 	[] 
			}		

		if (_.isArray(json))
			c.link = operators['ARRAY'].link
			for j in json
				cltemp = self.jsonToClauses(c, j)
				if (_.isArray(cltemp))
					for clt in cltemp
						if (_.isObject(clt))
							clause.push(clt)

		else if (_.isObject(json))
			c.link = operators['OBJECT'].link
			clause = self.jsonToClauses(c, json)

				
		return clause


	clauseToStmt: (c) ->
		self = @
		stmt = ""		
		if (_.isArray(c.values) and c.values.length >= 1)
			stmt += " #{c.link} ("
			c.link = operators['ARRAY'].link
			x=1
			for v in c.values
				exp = self.buildExpression(c.expression, { column: c.column, value: v, op: c.op })
				if (x>1) then stmt+= "#{c.link}"
				stmt += " ( #{exp} ) "
				x++
			stmt += ")"
		else if (c.value)
			c.link = operators['OBJECT'].link
			exp = self.buildExpression(c.expression, { column: c.column, value: c.value, op: c.op })
			stmt += " #{c.link} ( #{exp} ) "
			x++
		
		return stmt

	getKeys: ->
	

	jsonToStmt: (json, where) ->
		self = @
		if (!where) then where = ''
		c = @jsonToClause(json)
		if (_.isArray(c))
			for data in c
				if (_.isArray(data))
					self.jsonToStmt(data, where)
				else if (_.isObject(data))
					where += self.clauseToStmt(data)
		else if (_.isObject(c))
			where += self.clauseToStmt(c)

		return where
	getValues: (whereClause, where, clause) ->
		if (_.isArray(whereClause))
			# ARRAY

		else if (_.isObject(whereClause))
			# OBJECT
			for key, value of whereClause
				if (key.substring(0,1) is '$')
					# OPERATOR
					operators[key]
				else
					values.column = key

				if (_.isObject(value)) 
					# OBJECT
				else if (_.isArray(value))
					# ARRAY
				else
					# VALUE
		else
			# VALUE

	build: (data) ->
		clause =  {
			link: 		operators['DEFAULT'].link
			op: 		operators['DEFAULT'].op
			expression: operators['DEFAULT'].expression
			column: 	'' 
			value: 		'' 
			values: 	[] 
		}
		return @getValues(data, where, clause)
