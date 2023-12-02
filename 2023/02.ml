#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

open Str
module StringMap = Map.Make (String)

let get_colour_counts line =
  line
  |> Str.split (Str.regexp " *[:;,] *")
  |> List.tl
  |> List.map (fun colour_count_string ->
    let pair = Str.split (Str.regexp "  *") colour_count_string in
    int_of_string (List.nth pair 0), List.nth pair 1)
;;

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
         acc + if is_possible (get_colour_counts line) then game_id else 0)
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
         get_colour_counts line
         |> List.fold_left
              (fun colour_maxes (count, colour) ->
                (match StringMap.find_opt colour colour_maxes with
                 | Some count -> count
                 | None -> 0)
                |> Int.max count
                |> yield_self (fun new_value ->
                  StringMap.add colour new_value colour_maxes))
              StringMap.empty
         |> yield_self (fun colour_maxes -> acc + power colour_maxes))
       0
  |> yield_self (fun answer -> Printf.printf "Part 2: %d\n" answer)
;;
