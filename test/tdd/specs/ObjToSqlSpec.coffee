SqlExpression = require('../lib/SqlExpression')

describe 'sql expression tests', ->

  it 'should transform json into sql where clause', ->
    expect(SqlExpression.build()).toEqual(" ( login = 'deividy' OR login = 'deeividy' OR login = 'itsme!' ) OR ( id = 1 AND login = 'de' ) AND ( age > 20 AND age < 30 ) OR ( name = 'Zachetti' AND login = 'tet' ) AND ( name = 'Deividy Metheler Zachetti' ) ")
