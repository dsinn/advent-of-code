#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

open Str
module StringMap = Map.Make (String)

let () =
  let colour_limits = StringMap.of_list [ "red", 12; "green", 13; "blue", 14 ] in
  let is_possible colour_counts =
    colour_counts
    |> List.for_all (fun (count, colour) -> count <= StringMap.find colour colour_limits)
  in
  File.lines_of "02.txt"
  |> Enum.fold
       (fun acc line ->
         Str.search_forward (Str.regexp "[0-9]+") line 0 |> ignore;
         let game_id = Str.matched_string line |> int_of_string in
         let colour_counts =
           line
           |> Str.split (Str.regexp " *[:;,] *")
           |> List.tl (* Game ID already parsed above *)
           |> List.map (fun colour_count_string ->
             let pair = Str.split (Str.regexp "  *") colour_count_string in
             int_of_string (List.nth pair 0), List.nth pair 1)
         in
         acc + if is_possible colour_counts then game_id else 0)
       0
  |> yield_self (fun answer -> Printf.printf "Part 1: %d\n" answer)
;;

let () =
  let power colour_maxes =
    colour_maxes |> StringMap.bindings |> List.map snd |> List.fold_left ( * ) 1
  in
  File.lines_of "02.txt"
  |> Enum.fold
       (fun acc line ->
         let colour_maxes =
           line
           |> Str.split (Str.regexp " *[:;,] *")
           |> List.tl (* Game ID not needed *)
           |> List.fold
                (fun colour_maxes colour_count_string ->
                  let pair = Str.split (Str.regexp "  *") colour_count_string in
                  let count = int_of_string (List.nth pair 0) in
                  let colour = List.nth pair 1 in
                  (match StringMap.find_opt colour colour_maxes with
                   | Some count -> count
                   | None -> 0)
                  |> Int.max count
                  |> yield_self (fun new_value ->
                    StringMap.add colour new_value colour_maxes))
                StringMap.empty
         in
         acc + power colour_maxes)
       0
  |> yield_self (fun answer -> Printf.printf "Part 2: %d\n" answer)
;;
