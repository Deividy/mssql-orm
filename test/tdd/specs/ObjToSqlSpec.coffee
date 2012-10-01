SqlExpression = require('../lib/SqlExpression')

describe 'sql expression tests', ->
	it 'should transform a json *clause* in a sql clause', ->
		clause =  {
			link: 		'AND' 
			op: 		'='
			expression:	'$COLUMN$ $OP$ $VALUE$'			
			column: 	'login' 
			value: 		'' 
			values: 	[ 'deividy', 'de', 'itsme!' ] 
		}		
		expect(SqlExpression.clauseToStmt(clause)).toEqual(" AND ( ( login = 'deividy' ) OR ( login = 'de' ) OR ( login = 'itsme!' ) )")

	it 'should transform a json in a json *clause*', ->
		json = { login: [ 'deividy', 'de', 'itsme!' ], pass: 123 }
		clauses = []
		clause =  {
			link: 		'AND' 
			op: 		'='
			expression:	'$COLUMN$ $OP$ $VALUE$'			
			column: 	'login' 
			value: 		'' 
			values: 	[ 'deividy', 'de', 'itsme!' ] 
		}		
		clauses.push(clause)

		clause =  {
			link: 		'AND' 
			op: 		'='
			expression:	'$COLUMN$ $OP$ $VALUE$'			
			column: 	'pass' 
			value: 		123 
			values: 	[] 
		}		
		clauses.push(clause)

		expect(SqlExpression.jsonToClause(json)).toEqual(clauses)
	
	it 'should transform a json with operator in a json array *clause*', ->
		expected = []
		
		json = { age: { '$gt': 20,'$lt': 30 } }

		clause = {
			link: 		'AND' 
			op: 		'>'
			expression:	'$COLUMN$ $OP$ $VALUE$'			
			column: 	'age' 
			value: 		20
			values: 	[] 
		}		
		expected.push(clause)
	
		clause = {
			link: 		'AND' 
			op: 		'<'
			expression:	'$COLUMN$ $OP$ $VALUE$'			
			column: 	'age' 
			value: 		30 
			values: 	[] 
		}		
		expected.push(clause)

		expect(SqlExpression.jsonToClause(json)).toEqual(expected)

	it 'should transform a json in a sql clause', ->
		json = [ { login: [ 'deividy', 'dex', 'itsme!' ], pass: 123 }, { login: 'test' } ]
		expect(SqlExpression.jsonToStmt(json)).toEqual(" OR ( ( login = 'deividy' ) OR ( login = 'dex' ) OR ( login = 'itsme!' )  AND ( pass = '123' ) ) OR ( login = 'test' ) ")
###
	it 'should transform json into sql where clause', ->
		data = [ 
			{ login: [ 'deividy', 'deeividy', 'itsme!' ] }, # 0
			[ { id: 1, login: 'de' } ],                     # 1
			{ age: { '$gt': 20,	'$lt': 30 } },				# 2             
			{ '$or': { name: 'Zachetti', login: 'tet' } },  # 3
			{ name: 'Deividy Metheler Zachetti' }           # 4 
		]
		expect(SqlExpression.build(data)).toEqual(" ( ( login = 'deividy' ) OR ( login = 'deeividy' ) OR ( login = 'itsme!' ) ) OR ( ( id = 1 ) AND ( login = 'de' ) ) AND ( age > 20 ) AND ( age < 30 ) OR ( ( name = 'Zachetti' ) AND ( login = 'tet' ) ) AND ( name = 'Deividy Metheler Zachetti' ) ")

###
