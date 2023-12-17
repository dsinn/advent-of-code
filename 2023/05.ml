#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

open Str

let rec find_lowest_location_number src_start src_end map_ranges =
  if List.is_empty map_ranges
  then src_start
  else (
    let head_range = List.hd map_ranges in
    try
      let map_range_start, map_range_end, offset =
        List.find
          (fun (map_range_start, map_range_end, _) ->
            (map_range_start <= src_start && src_start <= map_range_end)
            || (map_range_start <= src_end && src_end <= map_range_end))
          head_range
      in
      if src_start = src_end
      then
        find_lowest_location_number
          (src_start + offset)
          (src_end + offset)
          (List.tl map_ranges)
      else (
        let overlap_start = Int.max src_start map_range_start in
        let overlap_end = Int.min src_end map_range_end in
        [ find_lowest_location_number
            (overlap_start + offset)
            (overlap_end + offset)
            (List.tl map_ranges)
        ; (if overlap_start > src_start
           then find_lowest_location_number src_start (overlap_start - 1) map_ranges
           else Int.max_num)
        ; (if overlap_end < src_end
           then find_lowest_location_number (overlap_end + 1) src_end map_ranges
           else Int.max_num)
        ]
        |> List.min)
    with
    | Not_found -> find_lowest_location_number src_start src_end (List.tl map_ranges))
;;

let seed_data, map_triplet_lists =
  read_file "05.txt"
  |> Str.replace_first (Str.regexp "^seeds: ") ""
  |> Str.split (Str.regexp "\n\n[^0-9]+:\n")
  |> List.map (fun group ->
    Str.split (Str.regexp "\n") group
    |> List.map (fun line -> Str.split (Str.regexp " ") line |> List.map int_of_string))
  |> fun groups ->
  ( List.hd groups |> List.hd
  , List.tl groups
    |> List.map (fun triplet_list ->
      List.map
        (fun triplet ->
          match triplet with
          | [ a; b; c ] -> a, b, c
          | _ ->
            failwith
              (List.map string_of_int triplet
               |> String.concat " "
               |> Printf.sprintf "Invalid map data: %s"))
        triplet_list) )
;;

let map_ranges =
  List.map
    (fun triplet_list ->
      List.map
        (fun (dest_start, src_start, range) ->
          src_start, src_start + range - 1, dest_start - src_start)
        triplet_list)
    map_triplet_lists
;;

let () =
  seed_data
  |> List.fold_left
       (fun min seed -> find_lowest_location_number seed seed map_ranges |> Int.min min)
       Int.max_num
  |> Printf.printf "Part 1: %d\n"
;;

let () =
  let rec pair_elements l =
    match l with
    | [] -> []
    | start :: length :: rest -> (start, length) :: pair_elements rest
    | _ -> failwith "Odd number of seed_ranges found"
  in
  pair_elements seed_data
  |> List.fold_left
       (fun min (start, length) ->
         find_lowest_location_number start (start + length - 1) map_ranges |> Int.min min)
       Int.max_num
  |> Printf.printf "Part 2: %d\n"
;;
