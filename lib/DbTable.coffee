class DbTable
	constructor: (@table) ->

	getTable: -> 
		@table

	select: ->
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