open Js_of_ocaml.Js

class type error = object
  method code : int readonly_prop
  method content : js_string t optdef readonly_prop
end

class type login = object
  method signup_name_ : js_string t prop
  method signup_pwd_ : js_string t prop
  method signup_error_ : error t optdef prop
  method login_name_ : js_string t prop
  method login_pwd_ : js_string t prop
  method login_error_ : error t optdef prop
  method connected : bool t prop
end

class type app = object
  method path : js_string t prop
  method database : js_string t prop
  method db_version_ : int prop
  method login : login t readonly_prop
end

class type computed = object
  method signup_name_state_ : bool t opt prop
  method signup_pwd_state_ : bool t opt prop
  method login_name_state_ : bool t opt prop
  method login_pwd_state_ : bool t opt prop
end
