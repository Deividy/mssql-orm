class DatabaseSchema
	constructor: (@conn) ->


	connect: (callback) ->
		self = @
		@conn.connect((err)->
			if (err) 
				console.error('Error: ', err)
			else
				self.conn.on('error', (error) ->
				  console.error('Received error', error)
				)
				self.conn.on('message', (message) ->
				  console.info('Received info', message)
				)
				callback(self.conn)
		)

	execute: (stmt, callback) ->
		data = []
		@connect((conn) ->
			stmt = conn.createStatement(stmt)
			stmt.on('row', (row) ->
				data.push(row)
			)
			stmt.on('done', (done) ->
				callback(data)
			)
			stmt.execute()
		)
### OUTPUT DESIRED
{
	tables: {
		"users": {
			pk: ['users_id'],
			uq: [],
			fk: [],
			columns: {
				'users_id': {
	
				},
				'login': {
	
				},
				'pass': {
	
				}
			},
			hasMany: [ 'msgs' ]
		}
	}
}
###
#  --------- @Usage --------------------- #
tds = require('tds')
fs = require('fs')
util = require("util")

env = "development"

data = JSON.parse(fs.readFileSync("./config.json", "utf-8"))
config = data[env].database.mssql

conn = new tds.Connection({
	host:		config.host
	port:		config.post
	userName:	config.userName
	password:	config.password
	database:	config.database
})	

m = new DatabaseSchema(conn)
### Values mapper
SELECT * FROM INFORMATION_SCHEMA.TABLES
# 0 = Table_Catalog (DB NAME) / 1 = Table_Schema  (dbo) / 2 = Table_Name (TABLE NAME) / 3 = Table_Type (Type)


###
m.execute("SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS", (data) ->
	data.forEach((item)->
		console.log(item.getValue(2))
	)
)