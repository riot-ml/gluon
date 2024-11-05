type error =
  | Connection_closed
  | Could_not_resolve_uri of Uri.t
  | Uri_has_no_host of Uri.t
  | Unix_error of {
      name : string;
      reason : Unix.error;
      syscall : string;
      args : string;
    }
  | Syscall_would_block of { name : string; syscall : string; args : string }

let pp_err fmt err =
  match err with
  | Connection_closed ->
      Format.fprintf fmt "The connection was unexpectedly closed"
  | Could_not_resolve_uri uri ->
      Format.fprintf fmt "Could not resolve URI: %a" Uri.pp uri
  | Uri_has_no_host uri -> Format.fprintf fmt "URI has no host: %a" Uri.pp uri
  | Syscall_would_block { name; syscall; args } ->
      Format.fprintf fmt "Operation %S would block calling %S with args %S" name
        syscall args
  | Unix_error { name; reason; syscall; args } ->
      Format.fprintf fmt
        "Operation %S failed when calling syscall %S with arguments %S: %s" name
        syscall args
        (Unix.error_message reason)

let ( let* ) = Result.bind
let log = Format.printf

module Token = struct
  type t

  let unsafe_to_value x = Obj.magic x
  let unsafe_to_int t : int = unsafe_to_value t
  let hash t = Int.hash (unsafe_to_int t)

  let equal ?eq a b =
    match eq with
    | Some f -> f (unsafe_to_value a) (unsafe_to_value b)
    | None -> Int.equal (unsafe_to_int a) (unsafe_to_int b)

  let pp fmt t = Format.fprintf fmt "Token(%d)" (unsafe_to_int t)
  let make (x : 'whatever) : t = Obj.magic x
end

let rec syscall ~name fn =
  match fn () with
  | ok -> ok
  | exception Unix.(Unix_error (EINTR, _, _)) -> syscall ~name fn
  | exception Unix.(Unix_error ((EAGAIN | EWOULDBLOCK), syscall, args)) ->
      (* log "syscall is try again\n"; *)
      Error (Syscall_would_block { name; syscall; args })
  | exception Unix.(Unix_error (reason, syscall, args)) ->
      Error (Unix_error { name; reason; syscall; args })

module Fd = struct
  type t = Unix.file_descr

  let to_int fd = Obj.magic fd
  let make fd = fd
  let pp fmt t = Format.fprintf fmt "Fd(%d)" (Obj.magic t)
  let close t = Unix.close t
  let seek = Unix.lseek
  let equal a b = Int.equal (to_int a) (to_int b)
end

module Non_zero_int = struct
  type t = int

  let make a = if a > 0 then Some a else None
end

module Interest : sig
  type t

  val readable : t
  val writable : t
  val add : t -> t -> t
  val remove : t -> t -> t option
  val is_readable : t -> bool
  val is_writable : t -> bool
end = struct
  type t = Non_zero_int.t

  let readable = 0b0001
  let writable = 0b0010
  let add a b = a lor b
  let remove a b = Non_zero_int.make (a land lnot b)
  let is_readable t = t land readable != 0
  let is_writable t = t land writable != 0
end
