tds = require('tds')
class DbUtils
	@setConn: (@config) ->
		

	@connect: (callback) ->
		self = @
		@conn = new tds.Connection(@config)
		@conn.connect((err) ->
			if (err) 
				console.error('Received error: ', err)
			else
				self.conn.on('error', (error) ->
				  console.error('Received error', error)
				)
				self.conn.on('message', (message) ->
				  console.info('Received info', message)
				)
				callback(self.conn)
		)

	@execute: (stmt, callback) ->
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

module.exports = DbUtils
