; extends

(var_spec) @local.scope

(field_declaration
  name: (field_identifier) @local.definition.field)

(type_declaration
  (type_spec
    name: (type_identifier) @local.name
    type: [(struct_type) (interface_type)] @local.type)) @local.start
