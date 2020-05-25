open EzSession.TYPES

let (>>=) = Lwt.(>>=)

let challenge_size = 30
let randomChars = "abcdefghijklmnopqrstuvxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
let randomCharsLen = String.length randomChars

let random_challenge () =
  String.init challenge_size (fun _ -> randomChars.[Random.int randomCharsLen])

include EzSessionServer.Make(struct

    module SessionArg = Session_arg

    module SessionStore : EzSessionServer.SessionStore with type user_id = SessionArg.user_id = struct

      type user_id = SessionArg.user_id

      let create_session ~login session_user_id =
        let rec unused_cookie () =
          let token = random_challenge () in
          Db.get_session token >>= function
          | [] -> Lwt.return token
          | _ -> unused_cookie () in
        unused_cookie () >>= fun session_cookie ->
        let session_last = EzAPIServerUtils.req_time () in
        let s = {
          session_login = login;
          session_user_id; session_cookie; session_last;
          session_variables = StringCompat.StringMap.empty } in
        Db.add_session ~id:session_user_id ~token:session_cookie >>=
        fun () -> Lwt.return s

      let get_session ~cookie:token =
        Db.get_session token >>= function
        | [] -> Lwt.return None
        | (session_user_id, session_login, session_cookie) :: _ ->
          let last = EzAPIServerUtils.req_time () in
          let s = {session_login; session_user_id; session_cookie;
                   session_variables = StringCompat.StringMap.empty;
                   session_last = last } in
          Lwt.return (Some s)

      let remove_session id ~cookie =
        Db.remove_session ~id ~token:cookie

    end

    let find_user ~login:username = Db.get_user username
  end)
