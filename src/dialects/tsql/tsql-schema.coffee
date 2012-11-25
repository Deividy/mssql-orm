DbSchema = require('../../db-schema')
_ = require('underscore')
sql = require('../../sql')

class TsqlSchema extends DbSchema
    constructor: (@db) ->

    getTableNames: (callback) ->
        tables = []
        query =
            "SELECT TABLE_NAME name FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_TYPE = 'BASE TABLE'"

        @db.array(query, (err, a) ->
            if err then callback(err, null) else callback(null, a.sort())
        )

    getColumns: (callback) ->
        query =
            "SELECT
				TABLE_NAME tableName, COLUMN_NAME name, ORDINAL_POSITION position,
				COLUMNPROPERTY(OBJECT_ID(TABLE_NAME), COLUMN_NAME, 'IsIdentity') isIdentity,
				COLUMNPROPERTY(OBJECT_ID(TABLE_NAME), COLUMN_NAME, 'IsComputed') isComputed,
				IS_NULLABLE isNullable, DATA_TYPE dbDataType, CHARACTER_MAXIMUM_LENGTH maxLength
			FROM
				INFORMATION_SCHEMA.COLUMNS
			ORDER BY
				TABLE_NAME, ORDINAL_POSITION"

        @db.allRows(query, callback)

    getConstraints: (callback) ->
        query = "
            SELECT CONSTRAINT_NAME name, TABLE_NAME tableName, CONSTRAINT_TYPE type
            FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
            WHERE TABLE_NAME IS NOT NULL
        "

        @db.allRows(query, callback)

    getForeignKeys: (callback) ->
        query = "
            SELECT CONSTRAINT_NAME name, UNIQUE_CONSTRAINT_NAME parentConstraint
            FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
        "

        @db.allRows(query, callback)

    getKeyColumns: (callback) ->
        query = "
            SELECT
                CONSTRAINT_NAME constraintName, TABLE_NAME tableName, COLUMN_NAME columnName,
                ORDINAL_POSITION position 
            FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
            ORDER BY constraintName, position
        "

        @db.allRows(query, callback)

    buildDbTree: (callback) ->
        self = @
        dbTree = {}
        @getConstraints(dbTree, (tables) ->
            self.getColumns(tables, (tables) ->
                dbTree = { tables: tables }
                callback(dbTree)
            )
        )

    getDbTree: (callback) ->
        @buildDbTree(callback)

module.exports = TsqlSchema
