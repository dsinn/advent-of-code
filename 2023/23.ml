#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

let remove_dead_ends map =
  let y_max = Array.length map - 2 in
  let x_max = Array.length map.(0) - 1 in
  let dead_end_found = ref true in
  while !dead_end_found do
    dead_end_found := false;
    for y = 1 to y_max do
      for x = 0 to x_max do
        if map.(y).(x) <> '#'
           && [ y + 1, x; y - 1, x; y, x + 1; y, x - 1 ]
              |> List.count_matching (fun (y', x') ->
                try map.(y').(x') <> '#' with
                | Invalid_argument _ -> false)
              = 1
        then (
          map.(y).(x) <- '#';
          dead_end_found := true;
          (* @TODO Continue searching along this path and assigning '#' until you hit an intersection *)
          Printf.printf "Removed dead end at (%d, %d)\n" y x);
        flush stdout
      done
    done
  done
;;

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
    |> tap remove_dead_ends
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
