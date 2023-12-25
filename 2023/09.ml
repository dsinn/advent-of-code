#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

let rows_diffs =
  let rec pair_map f list =
    match list with
    | x :: y :: rest -> f x y :: pair_map f (y :: rest)
    | _ -> []
  in
  let rec calc_diffs row diffs =
    let next_row = pair_map (fun x y -> y - x) row in
    if List.for_all (( = ) 0) next_row
    then diffs
    else calc_diffs next_row (diffs @ [ next_row ])
  in
  File.lines_of "09.txt"
  |> Enum.map (fun line -> Str.split (Str.regexp " +") line |> List.map int_of_string)
  |> List.of_enum
  |> List.map (fun row -> calc_diffs row [ row ])
;;

let sum_extrapolees rows_diffs f_extrapolee =
  List.fold_left
    (fun sum row_diffs ->
      List.rev row_diffs |> List.fold_left f_extrapolee 0 |> ( + ) sum)
    0
    rows_diffs
;;

let () =
  sum_extrapolees rows_diffs (fun extrapolee diff -> List.last diff + extrapolee)
  |> Printf.printf "Part 1: %d\n"
;;

let () =
  sum_extrapolees rows_diffs (fun extrapolee diff -> List.hd diff - extrapolee)
  |> Printf.printf "Part 2: %d\n"
;;
