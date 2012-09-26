### Working on that...
class TableSchema
	getKeys: (callback) ->
		
	getConstraints: (callback) ->
		tables = []
		@execute("SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS", (data) ->
			fkeys = []
			data.forEach((item)->				
				colName = item.getValue(2)
				tblName = item.getValue(5)
				constraintKey = item.getValue(6)
				if (!tables[tblName]) then tables[tblName] = {}

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
