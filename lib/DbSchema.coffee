DbUtils = require("./DbUtils")

class DbSchema

	constructor: (config) ->
		DbUtils.setConn(config)

	execute: (stmt, callback) ->
		DbUtils.execute(stmt, callback)

	# Not using, yet.
	getAllTables: (tables, callback) ->
		@execute("SELECT * FROM INFORMATION_SCHEMA.TABLES", (data) ->
			data.forEach((item)->
				tblName = item.getValue('TABLE_NAME')
				tables[tblName] = {}
			)
			callback(tables)
		)

	getConstraints: (tables, callback) ->
		self =@
		@execute("SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS", (data) ->
			fkeys = []
			data.forEach((item)->
				colName = item.getValue('CONSTRAINT_NAME')
				tblName = item.getValue('TABLE_NAME')
				constraintKey = item.getValue('CONSTRAINT_TYPE')
				if (!tables[tblName]) then tables[tblName] = {}

				switch (constraintKey)
					when "PRIMARY KEY" then tables[tblName]["pk"] = colName.substring(3)
					when "FOREIGN KEY" then fkeys.push( { "tblName": tblName, fKey :colName  })					
					when "UNIQUE" then tables[tblName]["uq"] = colName.substring(3)
			)
			fkeys.forEach((fk) ->
				self.execute("SELECT a.CONSTRAINT_TYPE, a.TABLE_NAME, b.CONSTRAINT_NAME, b.UNIQUE_CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS a LEFT JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS b on a.CONSTRAINT_NAME = b.UNIQUE_CONSTRAINT_NAME WHERE b.CONSTRAINT_NAME = '#{fk.fKey}'", (data) ->
					data.forEach((item)->
						belongs = item.getValue('TABLE_NAME')
						fKey = item.getValue('CONSTRAINT_NAME')
						bkey = item.getValue('UNIQUE_CONSTRAINT_NAME')
						
						if (!tables[fk.tblName]["fk"]) then tables[fk.tblName]["fk"] = []
						tables[fk.tblName]["fk"].push(fKey)

						if (!tables[fk.tblName]["belongsTo"]) then tables[fk.tblName]["belongsTo"] = []
						tables[fk.tblName]["belongsTo"].push(belongs)

						if (!tables[belongs]["hasMany"]) then tables[belongs]["hasMany"] = []

						tables[belongs]["hasMany"].push(fk.tblName)
						callback(tables)
					)
				)
			)
		)

	getColumns: (tables, callback) ->
		@execute("SELECT * FROM INFORMATION_SCHEMA.COLUMNS", (data) ->
			data.forEach((item) ->
				if (!tables[item.getValue('TABLE_NAME')]['columns']) then tables[item.getValue('TABLE_NAME')]['columns'] = {}
				tables[item.getValue('TABLE_NAME')]['columns'][item.getValue('COLUMN_NAME')] = { 
				 	index: 			item.getValue('ORDINAL_POSITION')
				 	default:		item.getValue('COLUMN_DEFAULT')
				 	isNull:			item.getValue('IS_NULLABLE')
					type: 			item.getValue('DATA_TYPE')
					maxLength: 		item.getValue('CHARACTER_MAXIMUM_LENGTH')
					octLength: 		item.getValue('CHARACTER_OCTET_LENGTH')
				}
			)
			callback(tables)
		)
		
	mountDbTree: (callback) ->
		self = @
		dbTree = {}
		@getConstraints(dbTree, (tables) ->
			self.getColumns(tables, (tables) ->
				callback(tables)
			)
			
		)
		

	getDbTree: (callback) ->
		callback(@dbTree)

module.exports = DbSchema
