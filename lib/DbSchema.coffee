DbUtils = require("./DbUtils")

class DbSchema

	constructor: (config) ->
		DbUtils.setConfig(config)

	execute: (stmt, callback) ->
		DbUtils.execute(stmt, callback)

	getAllTablesName: (tables, callback) ->
		@execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES", (data) ->
			data.forEach((item)->
				tblName = item.getValue('TABLE_NAME')
				tables[tblName] = {}
			)
			callback(tables)
		)

	getConstraints: (tables, callback) ->
		self = @
		@execute("SELECT CONSTRAINT_NAME, TABLE_NAME, CONSTRAINT_TYPE FROM 
			INFORMATION_SCHEMA.TABLE_CONSTRAINTS", (data) ->
			fkeys = []
			data.forEach((item)->
				colName = item.getValue('CONSTRAINT_NAME')
				tblName = item.getValue('TABLE_NAME')
				constraintKey = item.getValue('CONSTRAINT_TYPE')

				if (!tables[tblName])
					tables[tblName] = {}
					tables[tblName]["fk"] = []
					tables[tblName]["belongsTo"] = []
					tables[tblName]["hasMany"] = []
					tables[tblName]['columns'] = {}

				switch (constraintKey)
					when "PRIMARY KEY" then tables[tblName]["pk"] = colName
					when "FOREIGN KEY" then fkeys.push( { "tblName": tblName, fKey :colName  })					
					when "UNIQUE" then tables[tblName]["uq"] = colName
			)
			fkeys.forEach((fk) ->
				self.execute("SELECT a.CONSTRAINT_TYPE, a.TABLE_NAME, b.CONSTRAINT_NAME, 
											b.UNIQUE_CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS a 

											LEFT JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS b 
											on a.CONSTRAINT_NAME = b.UNIQUE_CONSTRAINT_NAME 

									WHERE b.CONSTRAINT_NAME = '#{fk.fKey}'", 
				(data) ->
					data.forEach((item)->
						belongs = item.getValue('TABLE_NAME')
						fKey = item.getValue('CONSTRAINT_NAME')
						bkey = item.getValue('UNIQUE_CONSTRAINT_NAME')
						
						tables[fk.tblName]["fk"].push(fKey)
						tables[fk.tblName]["belongsTo"].push(belongs)
						tables[belongs]["hasMany"].push(fk.tblName)

						callback(tables)
					)
				)
			)
		)

	getColumns: (tables, callback) ->
		@execute("SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, COLUMN_DEFAULT, IS_NULLABLE, 
			DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, CHARACTER_OCTET_LENGTH FROM INFORMATION_SCHEMA.COLUMNS", 

		(data) ->
			data.forEach((item) ->
				tblName = item.getValue('TABLE_NAME')
				colName = item.getValue('COLUMN_NAME')

				tables[tblName]['columns'][colName] = { 
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
				tables = { tables: tables }
				callback(tables)
			)
		)
		
	getDbTree: (callback) ->
		@mountDbTree(callback)

module.exports = DbSchema
