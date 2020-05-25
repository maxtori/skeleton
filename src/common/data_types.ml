type 'a api_result = ('a, MRes.error) result

type version = {
  v_db: string;
  v_db_version: int;
}

type www_server_info = {
  www_apis : string list;
}

type signup = {
  login : string;
  pwhash : string
}

type change_pwd = {
  old_pwd : string;
  new_pwd : string
}
