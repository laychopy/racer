Schema = require '../index'

# TODO Add createField(opts) ?

NativeObjectId = require('mongodb').BSONPure.ObjectID
exports.ObjectId =
  _name: 'ObjectId'
  NativeObjectId: NativeObjectId

  cast: (val) ->
    return val if val instanceof NativeObjectId
    return @fromString val

  defaultTo: -> new NativeObjectId

  fromString: (str) ->
    unless 'string' == typeof str && 24 == str.length
      throw new Error 'Invalid ObjectId'
    return NativeObjectId.createFromHexString str

  toString: (oid) ->
    return NativeObjectId.toString() unless arguments.length
    return oid.toHexString()

exports.Array =
  _name: 'Array'
  
  cast: (list) ->
    return (@memberType.cast member for member in list)

# Object means an embedded document or the member of an embedded 
# array if this is a recursive inferType call
# TODO Can we remove exports.Object type?
exports.Object =
  _name: 'Object'
  cast: (val) ->
    return val.toJSON() if val instanceof Schema
    return val

exports.Ref =
  _name: 'Ref'

  cast: (val) ->
    return @pkeyType.cast val

  createField: ({pkeyType}) ->
    field = Object.create @
    field.pkeyType = pkeyType
    return field