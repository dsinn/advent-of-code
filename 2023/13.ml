#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

open Pcre

let transpose pattern =
  let src_rows = String.split_on_char '\n' pattern |> Array.of_list in
  let src_height = Array.length src_rows in
  let src_width = String.length src_rows.(0) in
  List.range 0 `To (src_width - 1)
  |> List.map (fun src_x ->
    List.range 0 `To (src_height - 1)
    |> List.map (fun src_y -> src_rows.(src_y).[src_x])
    |> List.to_seq
    |> String.of_seq)
  |> String.concat "\n"
;;

let calc_pattern_score pattern find_horizontal_reflection_index =
  match find_horizontal_reflection_index pattern with
  | Some y -> 100 * y
  | None ->
    (match find_horizontal_reflection_index (transpose pattern) with
     | Some x -> x
     | None ->
       raise (Invalid_argument ("Pattern does not contain any reflections:\n" ^ pattern)))
;;

let find_y_reflection_index_without_smudge pattern =
  let check_start_rex = Pcre.regexp ~flags:[ `MULTILINE ] "^(.++)\n\\1" in
  let rows = String.split_on_char '\n' pattern |> Array.of_list in
  let width = String.length rows.(0) in
  try
    Pcre.exec_all ~rex:check_start_rex pattern
    |> Array.map (fun substring ->
      Pcre.get_substring_ofs substring 0
      |> fst
      |> fun string_offset -> (string_offset / (width + 1)) + 1)
    |> Array.to_list
    |> List.find_opt (fun y_bot ->
      let y_top = y_bot - 1 in
      let max_offset = Int.min y_top (Array.length rows - y_bot - 1) in
      max_offset = 0
      || List.range 1 `To max_offset
         |> List.for_all (fun offset ->
           String.equal rows.(y_top - offset) rows.(y_bot + offset)))
  with
  | Not_found -> None
;;

let patterns = read_file "13.txt" |> Str.split (Str.regexp "\n\n")

let () =
  List.fold_left
    (fun sum pattern ->
      sum + calc_pattern_score pattern find_y_reflection_index_without_smudge)
    0
    patterns
  |> Printf.printf "Part 1: %d\n"
;;

let () =
  let string_distance s1 s2 =
    List.range 0 `To (String.length s1 - 1)
    |> List.count_matching (fun i -> s1.[i] <> s2.[i])
  in
  let rec mirror_check offsets smudges_allowed rows y_top y_bot =
    if smudges_allowed < 0
    then false
    else if smudges_allowed = 0
    then
      (* Assuming this is more performant *)
      List.for_all
        (fun offset -> String.equal rows.(y_top - offset) rows.(y_bot + offset))
        offsets
    else if List.is_empty offsets
    then true
    else (
      let offset = List.hd offsets in
      let distance = string_distance rows.(y_top - offset) rows.(y_bot + offset) in
      mirror_check (List.tl offsets) (smudges_allowed - distance) rows y_top y_bot)
  in
  let find_y_reflection_index_with_smudge pattern =
    let smudgeless_index =
      match find_y_reflection_index_without_smudge pattern with
      | Some index -> index
      | None -> -1
    in
    let rows = String.split_on_char '\n' pattern |> Array.of_list in
    List.range 1 `To (Array.length rows - 1)
    |> List.find_opt (fun y_bot ->
      y_bot <> smudgeless_index
      &&
      let y_top = y_bot - 1 in
      let initial_distance = string_distance rows.(y_top) rows.(y_bot) in
      initial_distance <= 1
      &&
      let max_offset = Int.min y_top (Array.length rows - y_bot - 1) in
      max_offset = 0
      || mirror_check
           (List.range 1 `To max_offset)
           (1 - initial_distance)
           rows
           y_top
           y_bot)
  in
  List.fold_left
    (fun sum pattern ->
      sum + calc_pattern_score pattern find_y_reflection_index_with_smudge)
    0
    patterns
  |> Printf.printf "Part 2: %d\n"
;;
