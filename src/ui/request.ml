open Data_types
module S = Services

(** API Utils *)

let host = ref (EzAPI.TYPES.BASE PConfig.web_host)

let wrap_res ?error f x = match x, error with
  | Ok x, _ -> f x
  | Error e, Some error -> let code, content = MRes.error_content e in
    error code content
  | _ -> ()

let get0 ?(host= !host) ?post ?headers ?params ?error ?(msg="") service f =
  EzXhr.get0 host service msg ?post ?headers ?error ?params (wrap_res ?error f) ()
let get1 ?(host= !host) ?post ?headers ?params ?error ?(msg="") service arg f =
  EzXhr.get1 host service msg ?post ?headers ?error ?params (wrap_res ?error f) arg
let post0 ?(host= !host) ?headers ?params ?error ?(msg="") ~input service f =
  EzXhr.post0 host service msg ?headers ?params ?error ~input (wrap_res ?error f)

(** Initialization of API server *)

let info_encoding = Json_encoding.(
    conv
      (fun {www_apis} -> www_apis)
      (fun www_apis -> {www_apis}) @@
    obj1
      (req "apis" (list string)))

let info_service : www_server_info EzAPI.service0 =
  EzAPI.service
    ~output:info_encoding
    EzAPI.Path.(root // "info.json" )

let init f =
  EzXhr.get0 (Ui.host ()) info_service ""
    ~error:(fun code content ->
        let s = match content with
          | None -> "network error"
          | Some content -> "network error: " ^ string_of_int code ^ " -> " ^ content in
        Ui.log_str s)
    (fun ({www_apis; _} as info) ->
       let api = List.nth www_apis (Random.int @@ List.length www_apis) in
       host := EzAPI.TYPES.BASE api;
       f info) ()

(** Session Requests *)

let sign_in ?error ~username ~password f =
  let login = Base64.encode_string ~pad:false @@ EzSession.Hash.hash username in
  Session.login !host ~login ~password @@ function
  | Error e -> let code, content = MRes.(error_content (Exn_err [e])) in
    (match error with None -> () | Some f -> f code content)
  | Ok auth -> Session.set_session username auth;
    f ()

let sign_out () =
  Session.with_session_token @@ fun token ->
  Session.logout !host ~token @@ function
  | Ok _ -> Session.clear_session ()
  | _ -> ()

let sign_up ?error ~username ~password f =
  let login = Base64.encode_string ~pad:false @@ EzSession.Hash.hash username in
  let pwhash = Base64.encode_string ~pad:false @@ EzSession.Hash.password ~login ~password in
  post0 ?error ~input:{login; pwhash} S.sign_up @@ fun _ ->
  sign_in ~username ~password f

let post0_session ?params ?error ?msg ~input service f =
  let none = match error with None -> None | Some f -> Some (fun () -> f 0 (Some "Not connected")) in
  Session.with_session_token ?none @@ fun token ->
  post0 ?params ?error ?msg ~headers:(Session.auth_headers ~token) ~input service f

let get0_session ?post ?params ?error ?msg service f =
  let none = match error with None -> None | Some f -> Some (fun () -> f 0 (Some "Not connected")) in
  Session.with_session_token ?none @@ fun token ->
  get0 ?post ?params ?error ?msg ~headers:(Session.auth_headers ~token) service f

let change_pwd old_pwd new_pwd f =
  Session.with_session @@ fun (_username, auth) ->
  let login = auth.Session.TYPES.auth_login in
  let old_pwd = Base64.encode_string ~pad:false @@ EzSession.Hash.password ~login ~password:old_pwd in
  let new_pwd = Base64.encode_string ~pad:false @@ EzSession.Hash.password ~login ~password:new_pwd in
  post0 ~headers:(Session.auth_headers ~token:auth.Session.TYPES.auth_token)
    ~input:{old_pwd; new_pwd} S.change_pwd f

(** Standard Requests *)
open Js_of_ocaml.Js

let version app =
  get0 S.version @@ fun {v_db; v_db_version} ->
  app##.database := string v_db;
  app##.db_version_ := v_db_version
