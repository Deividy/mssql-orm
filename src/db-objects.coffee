_ = require('underscore')

class DbObject
    toString: () ->
        s = "#{@constructor.name}: name='#{@name}'"
        s += ", alias=#{@alias}" if (@alias?)
        return s

    addEnforcingPosition: (array, newbie, position = newbie.position) ->
        expectedPosition = array.length + 1

        if expectedPosition != position
            msg = "Cannot add [#{newbie}] to [#{@}]. Expected position to be " +
                "#{expectedPosition} but it was #{position}"
            throw new Error(msg)

        array.push(newbie)

class Table extends DbObject
    constructor: (@db, schema) ->
        _.defaults(@, schema)
        @columns = []

        @columnsByName = {}
        @columnsByAlias = {}

        @keys = []
        @foreignKeys = []
        @incomingFKs = []
        @selfFKs = []

        @hasMany = []
        @belongsTo = []

        @db.tables.push(@)
        @db.tablesByName[@name] = @


    addColumn: (newbie) ->
        @addEnforcingPosition(@columns, newbie)
        @columnsByName[newbie.name] = newbie

class Column extends DbObject
    constructor: (@table, schema) ->
        _.defaults(@, schema)
        @isPartOfKey = false
        @isReadOnly = @isIdentity || @isComputed
        @isRequired = !@isNullable
        @table.addColumn(@)

    toString: () -> super.toString() + ", position=#{@position}"

class Constraint extends DbObject
    @types = ['PRIMARY KEY', 'UNIQUE', 'FOREIGN KEY']

    constructor: (@table, schema) ->
        _.defaults(@, schema)
        @columns = []
        @isKey = @type != 'FOREIGN KEY'
        @table.db.constraintsByName[@name] = @

    addColumn: (schema) ->
        col = @table.columnsByName[schema.columnName]
        col.isPartOfKey = true if @isKey
        @addEnforcingPosition(@columns, col, schema.position)


    toString: () -> super.toString() + ", type=#{@type}"

# Stolen friends and disease
# Operator, please
# Pass me back to my mind
class Key extends Constraint
    constructor: (@table, schema) ->
        super(@table, schema)
        @table.keys.push(@)

class ForeignKey extends Constraint
    constructor: (@table, schema) ->
        super(@table, schema)

        @parentKey = @table.db.constraintsByName[@parentKeyName]
        @parentTable = @parentKey.table

        if (@table == @parentTable)
            @table.selfFKs.push(@)
            return

        @table.foreignKeys.push(@)

        unless _.contains(@table.belongsTo, @parentTable)
             @table.belongsTo.push(@parentTable)

        unless _.contains(@parentTable.hasMany, @table)
            @parentTable.hasMany.push(@table)

        @parentTable.incomingFKs.push(@)


module.exports = { DbObject, Table, Column, Key, ForeignKey, Constraint }
