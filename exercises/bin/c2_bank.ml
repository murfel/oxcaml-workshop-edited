open! Core
open Await

(* Each balance lives in its own capsule, protected by its own mutex. *)
type account = int ref Capsule.Sync.With_mutex.t

module Name = struct
  type t = string

  let equal = String.equal
  let hash = String.hash
end

(* A concurrent hashtable from user name to account. *)
type t = (string, account) Portable_lockfree_htbl.t

let create () : t = Portable_lockfree_htbl.create (module Name)

let open_account (t : t) name ~(balance : int) : (unit, unit) Result.t =
  (* For you to implement *)
  Error ()
;;

let balance (sync : Sync.t @ local) (t : t) name : (int, unit) Result.t =
  (* For you to implement *)
  Error ()
;;

let transfer (sync : Sync.t @ local) (t : t) ~from ~to_ ~amount : (unit, unit) Result.t =
  (* For you to implement *)
  Error ()
;;

let print_balance (sync : Sync.t @ local) (t : t) name =
  match balance sync t name with
  | Ok balance -> printf "  %s: %d\n" name balance
  | Error () -> printf "  %s: no such user\n" name
;;

let result_to_string result = if Result.is_ok result then "ok" else "error"

(* Usage example: opens two accounts, makes a few transfers and prints the results. *)
let () =
  let sync = Sync.blocking in
  let bank = create () in
  let _ = open_account bank "alice" ~balance:100 in
  let _ = open_account bank "bob" ~balance:50 in
  let try_transfer ~from ~to_ ~amount =
    let result = transfer sync bank ~from ~to_ ~amount in
    printf "transfer %s -> %s %d: %s\n" from to_ amount (result_to_string result)
  in
  print_endline "initial balances:";
  print_balance sync bank "alice";
  print_balance sync bank "bob";
  try_transfer ~from:"alice" ~to_:"bob" ~amount:30;
  try_transfer ~from:"bob" ~to_:"alice" ~amount:500;
  try_transfer ~from:"alice" ~to_:"carol" ~amount:10;
  print_endline "final balances:";
  print_balance sync bank "alice";
  print_balance sync bank "bob"
;;
