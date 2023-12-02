#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

open Pcre
open Str
module StringMap = Map.Make (String)

let () =
  File.lines_of "01.txt"
  |> Enum.fold
       (fun acc line ->
         line
         |> Str.global_replace (Str.regexp "[^0-9]") ""
         |> yield_self (fun digits ->
           Printf.sprintf "%c%c" digits.[0] digits.[String.length digits - 1]
           |> int_of_string)
         |> yield_self (fun calibration_value -> acc + calibration_value))
       0
  |> yield_self (fun acc -> Printf.printf "Part 1: %d\n" acc)
;;

let () =
  let english_values =
    [ "one"; "two"; "three"; "four"; "five"; "six"; "seven"; "eight"; "nine" ]
    |> List.mapi (fun i english -> english, i + 1 |> string_of_int)
    |> StringMap.of_list
  in
  let value_pattern =
    "\\d|" ^ (StringMap.bindings english_values |> List.map fst |> String.concat "|")
  in
  let first_rex = value_pattern |> Pcre.regexp in
  let last_rex =
    Printf.sprintf "(?!.+(?:%s))(?:%s)" value_pattern value_pattern |> Pcre.regexp
  in
  File.lines_of "01.txt"
  |> Enum.fold
       (fun acc line ->
         line
         |> yield_self (fun line ->
           [ first_rex; last_rex ] |> List.map (fun rex -> Pcre.exec ~rex line))
         |> List.map (fun substring -> Pcre.get_substring substring 0)
         |> List.map (fun calibration_string ->
           match StringMap.find_opt calibration_string english_values with
           | Some value -> value
           | None -> calibration_string)
         |> String.concat ""
         |> int_of_string
         |> yield_self (fun calibration_value -> acc + calibration_value))
       0
  |> yield_self (fun acc -> Printf.printf "Part 2: %d\n" acc)
;;
