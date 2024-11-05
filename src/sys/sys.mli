open Gluon_common
open Gluon_events

module Selector : sig
  type t

  val name : string
  val make : unit -> (t, [> error ]) result

  val select :
    ?timeout:int64 -> ?max_events:int -> t -> (Event.t list, [> error ]) result

  val register :
    t ->
    fd:Fd.t ->
    token:Token.t ->
    interest:Interest.t ->
    (unit, [> error ]) result

  val reregister :
    t ->
    fd:Fd.t ->
    token:Token.t ->
    interest:Interest.t ->
    (unit, [> error ]) result

  val deregister : t -> fd:Fd.t -> (unit, [> error ]) result
end

module Event : sig
  type t
end
