#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

open Pcre
open Str
module StringMap = Map.Make (String)

exception Break1 of int
exception Break2 of (int * int list)

let directions, map_list =
  read_file "08.txt"
  |> fun content ->
  match Str.split (Str.regexp "\n\n") content with
  | [ directions_string; map_lines ] ->
    ( directions_string
      |> String.to_seq
      |> Array.of_seq
      |> Array.map (fun direction_char ->
        match direction_char with
        | 'L' -> 0
        | 'R' -> 1
        | _ -> failwith (Printf.sprintf "Invalid direction: %c" direction_char))
    , Str.split (Str.regexp "\n") map_lines
      |> List.map (fun line ->
        match Str.split (Str.regexp "[^A-Z0-9]+") line with
        | [ key; left; right ] -> key, [| left; right |]
        | _ -> failwith (Printf.sprintf "Invalid map line: %s" line)) )
  | tokens ->
    failwith
      (Printf.sprintf
         "Invalid input; expected 2 tokens separated by two newlines but found %d in:\n\n\
          %s"
         (List.length tokens)
         content)
;;

let map = StringMap.of_list map_list

let () =
  let compute_steps directions map =
    try
      let directions_length = Array.length directions in
      BatEnum.range 0
      |> BatEnum.fold
           (fun current_location step ->
             if String.equal current_location "ZZZ" then raise (Break1 step);
             let direction = directions.(step mod directions_length) in
             (StringMap.find current_location map).(direction))
           "AAA"
      |> ignore;
      -1
    with
    | Break1 result -> result
  in
  compute_steps directions map |> Printf.printf "Part 1: %d\n"
;;

let () =
  let compute_period_and_valid_steps directions map starting_node =
    try
      let directions_length = Array.length directions in
      let visited = Hashtbl.create (directions_length * StringMap.cardinal map) in
      BatEnum.range 0
      |> BatEnum.fold
           (fun (current_location, steps_at_z) step ->
             let next_steps_at_z =
               if Pcre.pmatch ~pat:"Z$" current_location
               then step :: steps_at_z
               else steps_at_z
             in
             let direction_index = step mod directions_length in
             let visited_key = current_location, direction_index in
             match Hashtbl.find_option visited visited_key with
             | Some previous_step ->
               raise
                 (Break2
                    ( step - previous_step
                    , (* Cutting a corner; assume that the answer must be in the cycle of every starting node *)
                      List.filter (( <= ) previous_step) next_steps_at_z ))
             | None ->
               Hashtbl.add visited visited_key step;
               let direction = directions.(direction_index) in
               let next_location = (StringMap.find current_location map).(direction) in
               next_location, next_steps_at_z)
           (starting_node, [])
      |> ignore;
      -1, []
    with
    | Break2 result -> result
  in
  let starting_nodes =
    List.map fst map_list |> List.filter (fun key -> Pcre.pmatch ~pat:"A$" key)
  in
  let rec gcd a b =
    if Big_int.equal b Big_int.zero then a else gcd b (Big_int.modulo a b)
  in
  let lcm a b = gcd a b |> Big_int.div (Big_int.mul a b |> Big_int.abs_big_int) in
  (*
     It seems that the input is crafted such that every ghost ends up on a Z node uniquely at the end of their cycle,
     AND that the starting node is always the beginning of a cycle???
     At least I made that _massive_ assumption and completely ignored the possibility of encountering multiple Z nodes
     in a cycle, so no need for the Chinese remainder theorem or any other "fancy" math.
  *)
  List.map (compute_period_and_valid_steps directions map) starting_nodes
  |> List.fold_left
       (fun product (period, _) -> Big_int.big_int_of_int period |> lcm product)
       (Big_int.big_int_of_int 1)
  |> Big_int.to_string
  |> Printf.printf "Part 2: %s\n"
;;
