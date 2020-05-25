let (>>=) = Lwt.(>>=)
let (>|=) = Lwt.(>|=)
let return = Lwt.return
let return_u = Lwt.return_unit

let (>>=?) v f =
  v >>= function
  | Error _ as err -> return err
  | Ok v -> f v

let (>>|?) v f = v >>=? fun v -> return (Ok (f v))

let map_res_s f l =
  Lwt_list.fold_left_s (fun acc x -> match acc with
      | Error e -> return (Error e)
      | Ok acc -> f x >>|? fun r -> r :: acc) (Ok []) l >>|? fun l ->
  List.rev l
