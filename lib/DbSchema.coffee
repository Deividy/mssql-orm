DbUtils = require("./DbUtils")

class DbSchema

	constructor: (@conn) ->
		DbUtils.setConn(@conn)

	execute: (stmt, callback) ->
		DbUtils.execute(stmt, callback)

	getAllTables: (tables, callback) ->
		@execute("SELECT * FROM INFORMATION_SCHEMA.TABLES", (data) ->
			data.forEach((item)->
				tblName = item.getValue(2)
				tables[tblName] = {}
			)
			callback(tables)
		)

	getConstraints: (tables, callback) ->
		@execute("SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS", (data) ->
			fkeys = []
			data.forEach((item)->
				colName = item.getValue(2)
				tblName = item.getValue(5)
				constraintKey = item.getValue(6)
				if (!tables[tblName]) then tables['tblName'] = {}

				switch (constraintKey)
					when "PRIMARY_KEY" then tables[tblName].push({ "pk": "#{colName}"})
					when "FOREIGN_KEY" then fkeys.push(colName)					
					when "UNIQUE" then tables[tblName].push({ "uq": "#{colName}"})
			)
			fkeys.forEach((fk) ->
				console.log(fk)
			)
			callback(tables)
		)
		
	mountDbTree: (callback) ->
		self = @
		@dbTree = []
		@getAllTables(@dbTree, (tables) ->
			self.getConstraints(tables, (tables) ->
				self.dbTree = tables
			)
		)

	getDbTree: (callback) ->
		callback(@dbTree)

module.exports = DbSchema
