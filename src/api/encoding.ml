open Json_encoding
open Data_types

let version = conv
  (fun {v_db; v_db_version} -> (v_db, v_db_version))
  (fun (v_db, v_db_version) -> {v_db; v_db_version}) @@
  obj2
    (req "db" string)
    (req "db_version" int)

let error = conv
    MRes.error_content
    (fun (code, content) -> MRes.Gen_err (code, content)) @@
  obj2 (req "code" int) (opt "content" string)

let api_result encoding = union [
    case (obj1 (req "error" error))
      (function Error e -> Some e | _ -> None)
      (fun e -> Error e);
    case encoding
      (function Ok x -> Some x | _ -> None)
      (fun x -> Ok x) ]

let sign_up = conv
    (fun {login; pwhash} -> (login, pwhash))
    (fun (login, pwhash) -> {login; pwhash}) @@
  obj2 (req "login" string) (req "pwd" string)

let change_pwd = conv
    (fun {old_pwd; new_pwd} -> (old_pwd, new_pwd))
    (fun (old_pwd, new_pwd) -> {old_pwd; new_pwd}) @@
  obj2 (req "old_pwd" string) (req "new_pwd" string)
