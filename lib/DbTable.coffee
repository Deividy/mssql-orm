SqlStatement = require('./SqlStatement')

#DbTable just execute the queryes
class DbTable
	constructor: (@data) ->
		if(!@data) then @data = { }


	@insertOne: (where, callback) ->
	### @usage, something like that;
		sql = new SqlStatement(@tableSchema)
		stmt = sql.insert(where)
		db.execute(stmt, callback)
	###
	@updateOne: (where, callback) ->

	@deleteOne: (where, callback) ->

	@findOne: (where, callback) ->

	@findMany: (where, callback) ->

	@deleteMany: (where, callback) ->

	@updateMany: (where, callback) ->

	save: ->




module.exports = DbTable