Database = require("./Database")

class DbSchema

	constructor: (config) ->
		@db = new Database(config)

	getRows: (stmt, callback) ->
		@db.getRows(stmt, callback)

	getAllTablesName: (tables, callback) ->
		@getRows("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES", (data) ->
			data.forEach((item)->
				tblName = item.getValue('TABLE_NAME')
				tables[tblName] = {}
			)
			callback(tables)
		)

	getConstraints: (tables, callback) ->
		self = @
		@getRows("SELECT a.CONSTRAINT_NAME, a.TABLE_NAME, a.CONSTRAINT_TYPE, b.COLUMN_NAME
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS a 
			LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE b on
			a.CONSTRAINT_NAME = b.CONSTRAINT_NAME", (data) ->
			fkeys = []
			uniques = []
			fkColumns = []

			data.forEach((item)->
				colName = item.getValue('CONSTRAINT_NAME')
				tblName = item.getValue('TABLE_NAME')
				constraintKey = item.getValue('CONSTRAINT_TYPE')
				column = item.getValue('COLUMN_NAME')

				if (!tables[tblName])
					tables[tblName] = {}
					tables[tblName]['name'] = tblName
					tables[tblName]["fk"] = []
					tables[tblName]["uniques"] = []
					tables[tblName]["belongsTo"] = []
					tables[tblName]["hasMany"] = []
					tables[tblName]['columns'] = {}

				switch (constraintKey)
					when "PRIMARY KEY", "UNIQUE"
						if (!uniques[tblName])
							uniques[tblName] = []

						if (!uniques[tblName][colName])
							uniques[tblName][colName] = {}
							uniques[tblName][colName].columns = []
							uniques[tblName][colName].type = constraintKey.replace(" ","_")

						uniques[tblName][colName].columns.push(column)

					when "FOREIGN KEY" 
						if (!fkColumns[tblName])
							fkColumns[tblName] = []

						if (!fkColumns[tblName][colName])
							fkColumns[tblName][colName] = []

						fkColumns[tblName][colName].push(column)
						fkeys.push( { "tblName": tblName, fKey :colName  })
			)
			for tbl of uniques
				for ck of uniques[tbl]
					keys = { name: ck, columns: [] }
					for cl in uniques[tbl][ck].columns
						keys.columns.push(cl)

					keys.type = uniques[tbl][ck].type

				tables[tbl].uniques.push(keys)
			
			fkeys.forEach((fk) ->
				self.getRows("SELECT a.CONSTRAINT_TYPE, a.TABLE_NAME, b.CONSTRAINT_NAME,
											b.UNIQUE_CONSTRAINT_NAME, b.UPDATE_RULE, b.DELETE_RULE
											FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS a 

											LEFT JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS b 
											on a.CONSTRAINT_NAME = b.UNIQUE_CONSTRAINT_NAME 

									WHERE b.CONSTRAINT_NAME = '#{fk.fKey}'", 
				(data) ->
					data.forEach((item)->
						belongs = item.getValue('TABLE_NAME')
						tkey = item.getValue('UNIQUE_CONSTRAINT_NAME')
						ck = item.getValue('CONSTRAINT_NAME')

						targetKey = {
							name: 	 tkey
							columns: fkColumns[fk.tblName][ck]
						}
						fKey = {
							fk: 	  		ck
							targetKey: 	  	targetKey
							targetTable:   	belongs
							onDelete: 		item.getValue('DELETE_RULE')
							onUpdate: 		item.getValue('UPDATE_RULE')
						}

						tables[fk.tblName]["fk"].push(fKey)
						tables[fk.tblName]["belongsTo"].push(belongs)
						tables[belongs]["hasMany"].push(fk.tblName)

						callback(tables)
					)
				)
			)
		)

	getColumns: (tables, callback) ->
		@getRows("SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, COLUMN_DEFAULT, 
			IS_NULLABLE, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, CHARACTER_OCTET_LENGTH
			FROM INFORMATION_SCHEMA.COLUMNS", 	(data) ->

			data.forEach((item) ->
				tblName = item.getValue('TABLE_NAME')
				colName = item.getValue('COLUMN_NAME')

				tables[tblName]['columns'][colName] = { 
				 	index: 		item.getValue('ORDINAL_POSITION')
				 	default:	item.getValue('COLUMN_DEFAULT')
				 	isNull:		item.getValue('IS_NULLABLE')
					type: 		item.getValue('DATA_TYPE')
					maxLength: 	item.getValue('CHARACTER_MAXIMUM_LENGTH')
					octLength: 	item.getValue('CHARACTER_OCTET_LENGTH')
				}
			)
			callback(tables)
		)
		
	mountDbTree: (callback) ->
		self = @
		dbTree = {}
		@getConstraints(dbTree, (tables) ->
			self.getColumns(tables, (tables) ->
				dbTree = { tables: tables }
				callback(dbTree)
			)
		)
		
	getDbTree: (callback) ->
		@mountDbTree(callback)

module.exports = DbSchema