DbTable = require('./DbTable')
DbSchema = require('./DbSchema')

class DynamicModels extends DbSchema
	nameConvention: (name) ->
		# Up first char and format name (we can remove the tbl and other trashs..)
		upc = name.substring(0, 1)
		name = name.replace(upc, upc.toUpperCase());
		return name

	makeModels: (callback) ->
		self = @
		@getDbTree((tree)->
			tables = tree.tables
			models = {}
			for tableName, tableData of tables
				# Create the model
			    models[self.nameConvention(tableName)] = class extends DbTable
			    	tableName: tableName
			    	tableSchema: tableData

			    	@find: ->

			    	@persist: ->

			    	@delete: ->

			    	
			callback(models)
		)

module.exports = DynamicModels