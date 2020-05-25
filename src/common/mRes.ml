type error =
  | Str_err of string
  | Gen_err of (int * string option)
  | Exn_err of exn list

let error_content = function
  | Str_err s -> (0, Some s)
  | Gen_err (code, content) -> (code, content)
  | Exn_err e -> (1, Some (String.concat "\n" @@ List.map Printexc.to_string e))

let print_error e =
  let code, content = error_content e in
  Printf.printf "Error -> code: %d, content: %s\n%!" code (PMisc.unopt "empty" content)

let error e = Error e
let ok x = Ok x

let (>>?) v f =
  match v with
  | Error _ as err -> err
  | Ok v -> f v

let (>|?) v f = v >>? fun v -> Ok (f v)

let map_res f l =
  match List.fold_left (fun acc x -> match acc with
      | Error e -> Error e
      | Ok acc -> match f x with
        | Error e -> Error e
        | Ok x -> Ok (x :: acc)) (Ok []) l with
  | Error e -> Error e
  | Ok l -> Ok (List.rev l)

let mapi_res f l =
  match List.fold_left (fun (i, acc) x -> match acc with
      | Error e -> i+1, Error e
      | Ok acc -> match f i x with
        | Error e -> i+1, Error e
        | Ok x -> i+1, Ok (x :: acc)) (0, Ok []) l with
  | _, Error e -> Error e
  | _, Ok l -> Ok (List.rev l)

let map2_res f l1 l2 =
  match List.fold_left2 (fun acc x1 x2 -> match acc with
      | Error e -> Error e
      | Ok acc -> match f x1 x2 with
        | Error e -> Error e
        | Ok x -> Ok (x :: acc)) (Ok []) l1 l2 with
  | Error e -> Error e
  | Ok l -> Ok (List.rev l)

let map2i_res f l1 l2 =
  match List.fold_left2 (fun (i, acc) x1 x2 -> match acc with
      | Error e -> i+1, Error e
      | Ok acc -> match f i x1 x2 with
        | Error e -> i+1, Error e
        | Ok x -> i+1, Ok (x :: acc)) (0, Ok []) l1 l2 with
  | _, Error e -> Error e
  | _, Ok l -> Ok (List.rev l)
