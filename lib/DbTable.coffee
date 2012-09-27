class DbTable
	constructor: (@data) ->
			if(!@data) then @data = { }

	set: (column, value) ->
		@data[column] = value

	get: (column) ->
		return @data[column]

	insert: (data) ->
		console.log("INSERT")
		console.log(data)

	update: (data, where) ->
		console.log("UPDATE")
		console.log(data)
		console.log(where)

	save: ->
		self = @
		id = 0
		pk = ''
		if (typeof @data is "object" && typeof(@data.length) is "undefined")
			console.log("OBJECT")
			# Check keys
			@tableSchema.uniques.forEach((uks)->
				for col in uks.columns
					# Yah, i got that
					if (self.data[col]) then id = self.data[col]
					# Oh, i have a id so i'll use that
					if (self.data['id']) then id = self.data['id'] 
					# Set the PK column
					pk = col
			)

			if (!id)
				@insert(@data)
			else
				@update(@data, { pk: pk, id: id })

		else
			console.log("ARRAY")
			console.log(@data)


	find: (id, callback) ->

	fetchAll: (where, callback) ->

	# Waiting...
	query: ->
		self = @		
		if (!@whereStatment) then @whereStatment = []
		if (!@orderStatment) then @orderStatment = []

		where: (w) ->
			self.whereStatment.push(w)
		order: (o) ->
			self.orderStatment.push(o)
		limit: (l) ->
			self.limitStatment = l

		getWhere: (addOr) ->
			whstmt = ""
			if (!addOr)
				addOr = "AND"
			self.whereStatment.forEach((where) ->
				if (whstmt isnt "") then whstmt += " #{addOr} "
				if (typeof where is "object")
					for k, v of where
						if (k isnt v) 
							whstmt += "( #{k} = #{v} )"
						else 
							whstmt += "( #{k} )"
				else if (typeof where is "string")
					whstmt += "( #{where} )"
				
			)
			if (whstmt isnt "") then whstmt = " WHERE ( #{whstmt} )"
			return whstmt

		getOrder: ->
			orderstmt = ""
			self.orderStatment.forEach((order) ->
				if (orderstmt isnt "") then orderstmt += " , "
				if (typeof order is "object")
					for k, v of order
						if (k isnt v) 
							orderstmt += "( #{k} #{v} )"
						else 
							orderstmt += "( #{k} )"
				else if (typeof order is "string")
					orderstmt += "( #{order} )"
				
			)
			if (orderstmt isnt "") then orderstmt = " ORDER BY #{orderstmt}"
			return orderstmt

		getLimit: ->
			# How make limit in MSSQL?
			#if (self.limitStatment) 
				#return " LIMIT #{self.limitStatment}"
			#else 
				return ""

		getQuery: ->
			stmt = "SELECT * FROM #{self.table} #{@getWhere()} #{@getOrder()} #{@getLimit()}"
			return stmt;

module.exports = DbTable