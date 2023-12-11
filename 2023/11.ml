#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

let galaxy_map =
  File.lines_of "11.txt"
  |> Enum.map (fun line ->
    line |> String.to_seq |> List.of_seq |> List.map (( = ) '#') |> Array.of_list)
  |> Array.of_enum
;;

let galaxy_positions =
  Array.fold_lefti
    (fun positions y row ->
      Array.fold_lefti
        (fun positions x is_galaxy ->
          if is_galaxy then (y, x) :: positions else positions)
        positions
        row)
    []
    galaxy_map
;;

let expanded_universe_positions galaxy_map galaxy_positions expansion_factor =
  let expansion_addend = expansion_factor - 1 in
  let height = Array.length galaxy_map in
  let width = Array.length galaxy_map.(0) in
  Array.fold_righti
    (fun y row galaxy_positions ->
      if not (Array.exists (( = ) true) row)
      then
        List.map
          (fun (y', x') -> if y' > y then y' + expansion_addend, x' else y', x')
          galaxy_positions
      else galaxy_positions)
    galaxy_map
    galaxy_positions
  |> fun galaxy_positions ->
  let y_range = BatEnum.range 0 ~until:(height - 1) |> Array.of_enum in
  List.fold_right
    (fun x galaxy_positions ->
      if not (Array.exists (fun y -> galaxy_map.(y).(x)) y_range)
      then
        List.map
          (fun (y', x') -> if x' > x then y', x' + expansion_addend else y', x')
          galaxy_positions
      else galaxy_positions)
    (BatEnum.range 0 ~until:(width - 1) |> List.of_enum)
    galaxy_positions
;;

let sum_taxicab_distances galaxy_positions =
  let num_galaxies = List.length galaxy_positions in
  List.fold_lefti
    (fun sum i (y, x) ->
      BatEnum.range (i + 1) ~until:(num_galaxies - 1)
      |> BatEnum.fold
           (fun sum j ->
             let y', x' = List.nth galaxy_positions j in
             sum + Int.abs (y - y') + Int.abs (x - x'))
           sum)
    0
    galaxy_positions
;;

let () =
  [ 2; 1000000 ]
  |> List.iteri (fun i expansion_factor ->
    expanded_universe_positions galaxy_map galaxy_positions expansion_factor
    |> sum_taxicab_distances
    |> Printf.printf "Part %d: %d\n" (i + 1))
;;
