open Js_of_ocaml.Js

let () =
  let path = Route.init () in
  let login = Login.init () in
  let app = V.init ~login (string path) in
  Request.init @@ fun _ ->
  Route.route ~app path
