open Misc_db
open Db_lwt

let (>|=) = Lwt.(>|=)

let get_version () =
  with_dbh >>> fun dbh ->
  [%pgsql dbh "select value from ezpg_info where name = 'version'"]
  >|= version_of_rows

let get_session token =
  with_dbh >>> fun dbh ->
  [%pgsql dbh
    "select user_id, username, token from sessions \
     inner join accounts on id = user_id \
     where token = $token"]

let get_user username =
  with_dbh >>> fun dbh ->
  [%pgsql dbh "select pwhash, id from accounts where username = $username"]
  >|= one (fun (pwhash, id) -> Base64.decode_exn ~pad:false pwhash, id, ()) >|= Result.to_option

let check_pwhash ~username pwhash =
  with_dbh >>> fun dbh ->
  [%pgsql dbh "select id from accounts where username = $username and pwhash = $pwhash"]
  >|= one (fun _ -> ())

let add_session ~id ~token =
  let tsp = CalendarLib.Calendar.now () in
  with_dbh >>> fun dbh ->
  [%pgsql dbh "insert into sessions(user_id, token, tsp) values($id, $token, $tsp)"]

let remove_session ~id ~token =
  with_dbh >>> fun dbh ->
  [%pgsql dbh "delete from sessions where token = $token and user_id = $id"]

let add_account ~username ~pwhash =
  with_dbh >>> fun dbh ->
  [%pgsql dbh "insert into accounts(username, pwhash) values($username, $pwhash) \
               on conflict do nothing returning id"]

let change_pwd ~username pwhash =
  with_dbh >>> fun dbh ->
  [%pgsql dbh "update accounts set pwhash = $pwhash where username = $username"]
