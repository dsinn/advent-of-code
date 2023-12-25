#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

(*
   let nCr n r =
   let fact x = Enum.range 0 ~until:x |> Enum.fold (fun product i -> product * i) 1 in
   if n = r
   then 1
   else
   Enum.range (r + 1) ~until:n
   |> Enum.fold (fun product i -> product * i) 1
   |> ( * ) (fact (n - r))
   ;;
*)

type row =
  { conditions : string
  ; damage_groups : int list
  }

let count_arrangements row =
  let total_damaged = List.reduce ( + ) row.damage_groups in
  let total_operational = String.length row.conditions - total_damaged in
  let memo = String.count_string row.conditions "?" |> Hashtbl.create in
  let rec count pos damage_streak rem_damage_groups rem_damaged rem_operational =
    let memo_key = pos, damage_streak, rem_damage_groups, rem_damaged, rem_operational in
    if rem_damaged < 0 || rem_operational < 0
    then 0
    else if pos >= String.length row.conditions
    then
      if (List.is_empty rem_damage_groups
          || (List.length rem_damage_groups = 1
              && damage_streak = List.hd rem_damage_groups))
         && rem_damaged = 0
         && rem_operational = 0
      then 1
      else 0
    else if Hashtbl.mem memo memo_key
    then Hashtbl.find memo memo_key
    else if damage_streak
            >
            try List.hd rem_damage_groups with
            | Failure _ -> 0
    then 0
    else (
      let result =
        let pos' = pos + 1 in
        (* @TODO omg so much duplication *)
        match row.conditions.[pos] with
        | '#' ->
          count
            pos'
            (damage_streak + 1)
            rem_damage_groups
            (rem_damaged - 1)
            rem_operational
        | '.' ->
          if damage_streak > 0
          then
            if damage_streak = List.hd rem_damage_groups
            then count pos' 0 (List.tl rem_damage_groups) rem_damaged (rem_operational - 1)
            else 0
          else count pos' 0 rem_damage_groups rem_damaged (rem_operational - 1)
        | '?' ->
          count
            pos'
            (damage_streak + 1)
            rem_damage_groups
            (rem_damaged - 1)
            rem_operational
          +
          if damage_streak > 0
          then
            if damage_streak = List.hd rem_damage_groups
            then
              count
                (pos + 1)
                0
                (List.tl rem_damage_groups)
                rem_damaged
                (rem_operational - 1)
            else 0
          else count pos' 0 rem_damage_groups rem_damaged (rem_operational - 1)
        | invalid_char -> Printf.sprintf "Invalid character: %c" invalid_char |> failwith
      in
      Hashtbl.add memo memo_key result;
      result)
  in
  count 0 0 row.damage_groups total_damaged total_operational
;;

let rows =
  File.lines_of "12.txt"
  |> Enum.map (fun line ->
    match String.split_on_char ' ' line with
    | [ conditions; damage_groups_string ] ->
      { conditions
      ; damage_groups =
          String.split_on_char ',' damage_groups_string |> List.map int_of_string
      }
    | _ -> failwith (Printf.sprintf "Invalid line: \"%s\"" line))
  |> List.of_enum
;;

let () =
  List.fold_left (fun sum row -> count_arrangements row |> ( + ) sum) 0 rows
  |> Printf.printf "Part 1: %d\n"
;;

let () =
  List.fold_left
    (fun sum row ->
      { conditions = List.make 5 row.conditions |> String.concat "?"
      ; damage_groups =
          List.range 1 `To 5 |> List.fold_left (fun acc _ -> acc @ row.damage_groups) []
      }
      |> count_arrangements
      |> ( + ) sum)
    0
    rows
  |> Printf.printf "Part 2: %d\n"
;;
