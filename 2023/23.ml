#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

let rec longest_hike (y, x) distance visited possible_directions y_goal map =
  if y = y_goal
  then distance
  else
    possible_directions y x
    |> List.filter (fun (y', x') ->
      try map.(y').(x') <> '#' && not (Set.mem (y', x') visited) with
      | Invalid_argument _ -> false)
    |> List.fold_left
         (fun max_distance (y', x') ->
           longest_hike
             (y', x')
             (distance + 1)
             (Set.add (y', x') visited)
             possible_directions
             y_goal
             map
           |> Int.max max_distance)
         Int.min_num
;;

let () =
  let map =
    read_file "23.txt"
    |> String.split_on_char '\n'
    |> List.map (fun line -> String.to_seq line |> Array.of_seq)
    |> Array.of_list
  in
  [ (fun y x ->
      match map.(y).(x) with
      | '^' -> [ y - 1, x ]
      | '>' -> [ y, x + 1 ]
      | 'v' -> [ y + 1, x ]
      | '<' -> [ y, x - 1 ]
      | _ -> [ y + 1, x; y - 1, x; y, x + 1; y, x - 1 ])
  ; (fun y x -> [ y + 1, x; y - 1, x; y, x + 1; y, x - 1 ])
  ]
  |> List.iteri (fun part possible_directions ->
    longest_hike
      (0, 1)
      0
      (Set.of_list [ 0, 1 ])
      possible_directions
      (Array.length map - 1)
      map
    |> Printf.printf "Part %d: %d\n" (part + 1)
    |> tap (fun _ ->
      if part = 0
      then
        print_endline
          "WARNING: Part 2 took hours to run because I haven't optimized this yet :)")
    |> tap (fun _ -> flush stdout))
;;
