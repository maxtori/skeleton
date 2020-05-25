open Data_types
open Encoding

let section_main = EzAPI.section "API"

let version : version api_result EzAPI.service0 =
  EzAPI.service
    ~section:section_main
    ~name:"version"
    ~output:(api_result version)
    EzAPI.Path.(root // "version")

let sign_up : (signup, int32 list api_result) EzAPI.post_service0 =
  EzAPI.post_service
    ~section:section_main
    ~name:"sign_up"
    ~input:sign_up
    ~output:(api_result Json_encoding.(list int32))
    EzAPI.Path.(root // "sign_up")

let change_pwd : (change_pwd, unit api_result) EzAPI.post_service0 =
  EzAPI.post_service
    ~name:"change_pwd"
    ~input:change_pwd
    ~output:(api_result Json_encoding.empty)
    EzAPI.Path.(root // "change_pwd")
