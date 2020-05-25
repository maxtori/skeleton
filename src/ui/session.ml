open Js_of_ocaml
open Js
open EzSessionClient

include Make(Session_arg)

let session_storage f =
  match Optdef.to_option Dom_html.window##.sessionStorage with
  | None -> ()
  | Some storage -> f storage

let set_session username auth = session_storage (fun storage ->
    storage##setItem (string "auth") (Json.output (username, auth)))

let clear_session () = session_storage (fun storage ->
    storage##removeItem (Js.string "auth"))

let with_session ?(none=fun () -> ()) f = session_storage (fun storage ->
    match Js.Opt.to_option @@ storage##getItem (Js.string "auth") with
    | None -> none ()
    | Some s -> f (Json.unsafe_input s : (string * TYPES.auth)))

let with_session_token ?none f =
  with_session ?none (fun (_, auth) -> f auth.TYPES.auth_token)
