_ = require('underscore')
fs = require('fs')

operators = JSON.parse(fs.readFileSync("../../../lib/operators.json", "utf-8"))

module.exports = 
	buildExpression: ->
		
	getKeys: ->

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

	build: ->
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
a clause que queremos
		clause =  {
			link: 		'AND' 
			op: 		'='
			expression:	'$COLUMN$ $OP$ $VALUE$'			
			column: 	'login' 
			value: 		'' 
			values: 	[ 'deividy', 'deeividy', 'itsme!' ] 
		}
				
###
		data = [ 
			{ login: [ 'deividy', 'deeividy', 'itsme!' ] }, # 0
			[ { id: 1, login: 'de' } ],                     # 1
			{ age: { '$gt': 20,	'$lt': 30 } },				# 2             
			{ '$or': { name: 'Zachetti', login: 'tet' } },  # 3
			{ name: 'Deividy Metheler Zachetti' }           # 4 
		]
		clause =  {
			link: 		'' 
			op: 		''
			expression:	''			
			column: 	'' 
			value: 		'' 
			values: 	[] 
		}
		return @getValues(data, where, clause)
