#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

open Pcre
open Str

let schematic = read_file "03.txt"

(* Include "\n" for easier calculations ahead *)
let width = String.index_from schematic 0 '\n' + 1

let () =
  Pcre.exec_all ~pat:"\\d+" schematic
  |> Array.fold_left
       (fun sum substring ->
         let symbol_rex_pos = (Pcre.get_substring_ofs substring 0 |> fst) - 1 in
         let number_string = Pcre.get_substring substring 0 in
         let length = String.length number_string in
         (* Account for edge case where a part number is on the right edge *)
         let symbol_rex =
           Printf.sprintf
             "^([^\\n]{0,%d}|\\n[^\\n]{0,%d})[^\\n\\d\\.]"
             (length + 1)
             length
           |> Pcre.regexp
         in
         [ symbol_rex_pos - width; symbol_rex_pos; symbol_rex_pos + width ]
         |> List.filter (fun pos -> pos >= -1 && pos < String.length schematic)
         |> List.exists (fun pos ->
           (* Hack for the schematic starting with a part number *)
           (if pos = -1 then "." ^ schematic else Str.string_after schematic pos)
           |> Pcre.pmatch ~rex:symbol_rex)
         |> yield_self (fun has_adjacent_symbol ->
           sum + if has_adjacent_symbol then int_of_string number_string else 0))
       0
  |> Printf.printf "Part 1: %d\n"
;;

let () =
  Pcre.exec_all ~pat:"\\*" schematic
  |> Array.fold_left
       (fun sum substring ->
         let gear_offset = Pcre.get_substring_ofs substring 0 |> fst in
         let gear_column = gear_offset mod width in
         let line_start_offset = gear_offset - gear_column in
         [ line_start_offset - width; line_start_offset; line_start_offset + width ]
         |> List.filter (fun pos -> pos >= 0 && pos < String.length schematic)
         |> List.map (fun pos -> String.sub schematic pos (width - 1))
         |> List.map (fun line ->
           try
             Pcre.exec_all ~pat:"\\d+" line
             |> Array.fold_left
                  (fun adjacent_numbers substring ->
                    let number_string = Pcre.get_substring substring 0 in
                    let length = String.length number_string in
                    let offset = Pcre.get_substring_ofs substring 0 |> fst in
                    let leftmost_column = offset mod width in
                    let rightmost_column = leftmost_column + length - 1 in
                    if Int.abs (leftmost_column - gear_column) < 2
                       || Int.abs (rightmost_column - gear_column) < 2
                       || (leftmost_column < gear_column && rightmost_column > gear_column)
                    then int_of_string number_string :: adjacent_numbers
                    else adjacent_numbers)
                  []
           with
           | Not_found -> [])
         |> List.flatten
         |> yield_self (fun adjacent_numbers ->
           sum
           +
           if List.length adjacent_numbers = 2
           then List.reduce ( * ) adjacent_numbers
           else 0))
       0
  |> Printf.printf "Part 2: %d\n"
;;
