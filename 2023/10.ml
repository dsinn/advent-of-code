#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

module CharMap = Map.Make (Char)

let offsets_by_dir =
  [| 0, 1 (* right *); -1, 0 (* up *); 0, -1 (* left *); 1, 0 (* down *) |]
;;

let dir_by_pipe =
  [| [ 'J', 1; '-', 0; '7', 3 ] (* from left *)
   ; [ '7', 2; '|', 1; 'F', 0 ] (* from bottom *)
   ; [ 'L', 1; '-', 2; 'F', 3 ] (* from right *)
   ; [ 'J', 2; '|', 3; 'L', 0 ] (* from top *)
  |]
  |> Array.map (fun list -> CharMap.of_list list)
;;

let pipes_by_direction =
  Array.map (fun map -> CharMap.bindings map |> List.map fst |> Array.of_list) dir_by_pipe
;;

let map =
  File.lines_of "10.txt"
  |> Enum.map (fun line -> String.to_seq line |> Array.of_seq)
  |> Array.of_enum
;;

let loop_point_list =
  let animal_pos =
    match
      Array.find_mapi
        (fun y row ->
          Array.find_mapi (fun x c -> if c = 'S' then Some (y, x) else None) row)
        map
    with
    | Some pos -> pos
    | None -> failwith "No animal found"
  in
  let first_viable_pipe, direction =
    match
      Array.combine offsets_by_dir pipes_by_direction
      |> Array.find_mapi (fun dir ((y_offset, x_offset), pipes) ->
        try
          let y = fst animal_pos + y_offset in
          let x = snd animal_pos + x_offset in
          let pipe = map.(y).(x) in
          if Array.exists (( = ) pipe) pipes then Some ((y, x), dir) else None
        with
        | invalid_arg -> None)
    with
    | Some result -> result
    | None -> failwith "No connecting pipe found"
  in
  let rec get_loop_point_list map pos direction lst =
    let y, x = pos in
    let next_lst = pos :: lst in
    let pipe = map.(y).(x) in
    if pipe = 'S'
    then next_lst
    else (
      let next_dir = CharMap.find pipe dir_by_pipe.(direction) in
      let offset = offsets_by_dir.(next_dir) in
      let next_pos = y + fst offset, x + snd offset in
      get_loop_point_list map next_pos next_dir next_lst)
  in
  get_loop_point_list map first_viable_pipe direction []
;;

let () =
  List.length loop_point_list
  |> float_of_int
  |> (fun x -> x /. 2.0)
  |> ceil
  |> int_of_float
  |> Printf.printf "Part 1: %d\n"
;;

let () =
  loop_point_list
  |> List.filter (fun (y, x) ->
    match map.(y).(x) with
    (*
       A simple polygon's area can be computed from the coordinates of its corners alone;
       no need to track every point on the perimeter and do unnecessary pairwise math.
    *)
    | '|' | '-' -> false
    | _ -> true)
  |> shoelace_area
  |> (fun loop_area -> loop_area - (List.length loop_point_list / 2) + 1)
  |> Printf.printf "Part 2: %d\n"
;;
