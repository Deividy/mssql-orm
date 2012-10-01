#SqlStatement = require('./SqlStatement')

class DbTable
	constructor: (@data) ->
		if(!@data) then @data = { }


	@insertOne: (data, callback) ->
	### @usage, something like that;
		sql = new SqlStatement(@tableSchema)
		stmt = sql.insert(data)
		db.execute(stmt, callback)
	###
	@updateOne: (data, where, callback) ->

	@deleteOne: (where, callback) ->

	@findOne: (where, callback) ->

	@findMany: (where, callback) ->

	@deleteMany: (where, callback) ->

	@updateMany: (data, where, callback) ->

	save: ->




module.exports = DbTable
