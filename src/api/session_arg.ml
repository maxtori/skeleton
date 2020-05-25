type user_id = int32
type user_info = unit

let user_id_encoding = Json_encoding.int32
let user_info_encoding = Json_encoding.unit
let rpc_path = []
let token_kind = `CSRF "X-Csrf-Token"
