open Js_of_ocaml
open Js
open Ui
open Vtypes

let username_pattern = Regexp.regexp ".{3,}"
let pwd_pattern = Regexp.regexp "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[a-zA-Z0-9]{8,}$"

let check_pattern pattern s =
  if s = "" then None
  else match Regexp.string_match pattern s 0 with
    | Some _ -> Some true
    | _ -> Some false

let check_pattern_js pattern s = opt bool @@ check_pattern pattern (to_string s)

let check_login ~username ~password bname bpwd f cb =
  match to_opt to_bool bname, to_opt to_bool bpwd with
  | Some true, Some true -> f ~username ~password cb
  | _ -> ()

let set_connected (app:app t) =
  Session.with_session
    ~none:(fun _ -> app##.login##.connected := _false)
    (fun (username, _user_info) ->
       app##.login##.login_name_ := string username;
       app##.login##.connected := _true)

let sign_up (app:app t) =
  let id = app##.login in
  let username = to_string id##.signup_name_ in
  let password = to_string id##.signup_pwd_ in
  log_str "TEST";
  match to_opt to_bool (V.computed app)##.signup_name_state_,
        to_opt to_bool (V.computed app)##.signup_pwd_state_ with
  | Some true, Some true ->
    Request.sign_up
      ~error:(fun code content -> id##.signup_error_ := make_error code content)
      ~username ~password (fun () ->
          id##.signup_pwd_ := string "";
          set_connected app)
  | _ -> log_str "TEST2"

let sign_in (app:app t) =
  let id = app##.login in
  let username = to_string app##.login##.login_name_ in
  let password = to_string app##.login##.login_pwd_ in
  id##.login_error_ := undefined;
  match to_opt to_bool (V.computed app)##.login_name_state_,
        to_opt to_bool (V.computed app)##.login_pwd_state_ with
  | Some true, Some true ->
    Request.sign_in
      ~error:(fun code content -> id##.login_error_ := make_error code content)
      ~username ~password (fun () ->
          id##.login_pwd_ := string "";
          set_connected app)
  | _ -> ()

let sign_out (app:app t) =
  Request.sign_out ();
  app##.login##.login_name_ := string "";
  app##.login##.connected := _false

let init () =
  V.add_computed "signup_name_state" (fun app ->
      app##.login##.signup_error_ := undefined;
      check_pattern_js username_pattern app##.login##.signup_name_);
  V.add_computed "signup_pwd_state" (fun app ->
      app##.login##.signup_error_ := undefined;
      check_pattern_js pwd_pattern app##.login##.signup_pwd_);
  V.add_computed "login_name_state" (fun app ->
      app##.login##.login_error_ := undefined;
      check_pattern_js username_pattern app##.login##.login_name_);
  V.add_computed "login_pwd_state" (fun app ->
      convopt (fun b ->
          bool (to_bool b && app##.login##.login_error_ = undefined))
      @@ check_pattern_js pwd_pattern app##.login##.login_pwd_);
  V.add_method0 "sign_up" sign_up;
  V.add_method0 "sign_in" sign_in;
  V.add_method0 "sign_out" sign_out;
  object%js
    val mutable signup_name_ = string ""
    val mutable signup_pwd_ = string ""
    val mutable signup_error_ = undefined
    val mutable login_name_ = string ""
    val mutable login_pwd_ = string ""
    val mutable login_error_ = undefined
    val mutable connected = bool false
  end
