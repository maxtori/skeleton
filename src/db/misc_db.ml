(* open Data_types *)

let version_of_rows = function [ Some v ] -> Int32.to_int v | _ -> 0

let one f = function
  | [ x ] -> Ok (f x)
  | [] -> Error (MRes.Str_err "No element in DB")
  | _ -> Error (MRes.Str_err "Too many element in DB")
