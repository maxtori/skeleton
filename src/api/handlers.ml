open Data_types
open MLwt
open EzSession.TYPES

let (>>=) = Lwt.(>>=)
let return = EzAPIServerUtils.return

let version _params () =
  Db.get_version () >>= fun v_db_version -> return @@ Ok {
    v_db = PConfig.database;
    v_db_version
  }

let sign_up _params {login=username; pwhash} =
  Db.add_account ~username ~pwhash >>= function
  | [] -> return @@ Error (MRes.Str_err "Account already exists")
  | ids -> return @@ Ok ids

let get_session ?(error="session connection failed") params =
  Sessions.get_request_session params >|= function
  | None -> Error (MRes.Str_err error)
  | Some s -> Ok s

let get_session_login ?error params =
  get_session ?error params >>|? fun s -> s.session_login

let change_pwd params {old_pwd; new_pwd} =
  (get_session_login params >>=? fun username ->
   Db.check_pwhash ~username old_pwd >>= function
   | Error _ as e -> Lwt.return e
   | Ok () -> Db.change_pwd ~username new_pwd >|= MRes.ok ) >>= return
