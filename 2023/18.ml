#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

let perimeter plan = List.fold_left (fun sum (_offset, distance) -> sum + distance) 0 plan

let () =
  [ File.lines_of "18.txt"
    |> Enum.map (fun line ->
      line
      |> String.split_on_char ' '
      |> fun tokens ->
      match tokens with
      | [ dir_s; distance_s; _ ] ->
        ( (match dir_s with
           | "U" -> -1, 0
           | "D" -> 1, 0
           | "L" -> 0, -1
           | "R" -> 0, 1
           | unknown_dir -> failwith ("Unknown direction " ^ unknown_dir))
        , int_of_string distance_s )
      | _ -> failwith ("Invalid line:\n" ^ line))
    |> List.of_enum
  ; File.lines_of "18.txt"
    |> Enum.map (fun line ->
      line
      |> String.split_on_char ' '
      |> fun tokens ->
      match tokens with
      | [ _; _; hex ] ->
        ( (match hex.[7] with
           | '0' -> 0, 1
           | '1' -> 1, 0
           | '2' -> 0, -1
           | '3' -> -1, 0
           | unknown_dir ->
             String.make 1 unknown_dir |> ( ^ ) "Unknown direction " |> failwith)
        , int_of_string ("0x" ^ String.sub hex 2 5) )
      | _ -> failwith ("Invalid line:\n" ^ line))
    |> List.of_enum
  ]
  |> List.iteri (fun part plan ->
    let points, _ =
      List.fold_left
        (fun (points, (y, x)) ((y_offset, x_offset), distance) ->
          let y' = y + (y_offset * distance) in
          let x' = x + (x_offset * distance) in
          (y', x') :: points, (y', x'))
        ([ 0, 0 ], (0, 0))
        plan
    in
    shoelace_area points
    |> ( + ) ((perimeter plan / 2) + 1)
    |> Printf.printf "Part %d: %d\n" (part + 1))
;;
