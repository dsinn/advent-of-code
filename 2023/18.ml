#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

let shoelace_area points =
  if List.length points < 3 then failwith "A polygon needs more than two points";
  let rec pairwise_multiply acc lst1 lst2 =
    match lst1, lst2 with
    | [], _ | _, [] -> acc
    | x1 :: xs1, x2 :: xs2 -> pairwise_multiply ((x1 * x2) + acc) xs1 xs2
  in
  let x_coords = List.map fst points in
  let y_coords = List.map snd points in
  let x_shifted = List.tl x_coords @ [ List.hd x_coords ] in
  let y_shifted = List.tl y_coords @ [ List.hd y_coords ] in
  let multiplied = pairwise_multiply 0 x_coords y_shifted in
  let subtracted = pairwise_multiply 0 x_shifted y_coords in
  Int.abs ((multiplied - subtracted) / 2)
;;

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
