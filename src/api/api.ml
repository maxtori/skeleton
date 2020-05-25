open EzAPIServerUtils

module MakeRegisterer(S: module type of Services)(H:module type of Handlers) = struct

  let register dir =
    dir
    |> register S.version H.version
    |> register S.sign_up H.sign_up
    |> Sessions.register S.change_pwd H.change_pwd
    |> Sessions.register_handlers

end

module R = MakeRegisterer(Services)(Handlers)

let services =
  empty |> R.register
