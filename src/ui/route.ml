open Js_of_ocaml
open Js

let get_app ?app () = match app with
  | None -> !V.app
  | Some app -> app

let route ?app path =
  Ui.log_str ("route " ^ path);
  let app = get_app ?app () in
  app##.path := string path;
  match String.split_on_char '/' path with
  | [ path ] -> begin match path with
      | "version" -> Request.version app
      | _ -> ()
    end
  | _ -> ()

let route_js app path =
  route ~app (to_string path);
  Ui.set_path (to_string path)

let init () =
  V.add_method1 "route" route_js;
  let path = Ui.path () in
  Dom_html.window##.onpopstate := Dom_html.handler (fun _e ->
      route @@ Ui.path ();
      _true);
  path
