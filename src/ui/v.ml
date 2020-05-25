open Js_of_ocaml.Js

include Vue_js.Make(struct
    type data = Vtypes.app
    let id = "app"
  end)

let computed app : Vtypes.computed t = Unsafe.coerce app

let init ~login path =
  let data_js = object%js
    val mutable path = path
    val mutable database = string ""
    val mutable db_version_ = 0
    val login = login
  end in
  init ~data_js ()
