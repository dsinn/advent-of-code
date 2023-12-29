#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

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
         |> fun has_adjacent_symbol ->
         sum + if has_adjacent_symbol then int_of_string number_string else 0)
       0
  |> Printf.printf "Part 1: %d\n"
;;

exception Break

let () =
  let number_rex = Pcre.regexp "\\d+" in
  Pcre.exec_all ~pat:"\\*" schematic
  |> Array.fold_left
       (fun sum substring ->
         let gear_offset = Pcre.get_substring_ofs substring 0 |> fst in
         let gear_column = gear_offset mod width in
         let line_start_offset = gear_offset - gear_column in
         let search_start_pos = Int.max 0 (line_start_offset - width) in
         let search_end_pos =
           Int.min (String.length schematic) (line_start_offset + (2 * width)) - 1
         in
         let search_string =
           String.sub schematic search_start_pos (search_end_pos - search_start_pos)
         in
         let number_substrings =
           try Pcre.exec_all ~rex:number_rex search_string with
           | Not_found -> Array.make 0 (Pcre.exec ~pat:"" "")
         in
         (try
            Array.fold_left
              (fun adjacent_numbers substring ->
                let number_string = Pcre.get_substring substring 0 in
                let length = String.length number_string in
                let offset = Pcre.get_substring_ofs substring 0 |> fst in
                let leftmost_column = offset mod width in
                let rightmost_column = leftmost_column + length - 1 in
                if Int.abs (leftmost_column - gear_column) < 2
                   || Int.abs (rightmost_column - gear_column) < 2
                   || (leftmost_column < gear_column && rightmost_column > gear_column)
                then
                  if List.length adjacent_numbers >= 2
                  then raise Break
                  else int_of_string number_string :: adjacent_numbers
                else adjacent_numbers)
              []
              number_substrings
          with
          | Break -> [])
         |> (fun adjacent_numbers ->
              if List.length adjacent_numbers = 2
              then List.reduce ( * ) adjacent_numbers
              else 0)
         |> ( + ) sum)
       0
  |> Printf.printf "Part 2: %d\n"
;;
