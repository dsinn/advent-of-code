#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

type pos =
  { x : int
  ; y : int
  ; z : int
  }

let get_supporter_indices (b_start, b_end) bricks =
  let underside_z = Int.min b_start.z b_end.z - 1 in
  bricks
  |> Array.to_list
  |> List.filteri_map (fun i (b'_start, b'_end) ->
    if Int.max b'_start.z b'_end.z = underside_z
       && ((b_start.x <= b'_start.x && b'_start.x <= b_end.x)
           || (b'_start.x <= b_start.x && b_start.x <= b'_end.x))
       && ((b_start.y <= b'_start.y && b'_start.y <= b_end.y)
           || (b'_start.y <= b_start.y && b_start.y <= b'_end.y))
    then Some i
    else None)
;;

let rec do_physics bricks =
  let brick_did_fall = ref true in
  while !brick_did_fall do
    brick_did_fall := false;
    Array.iteri
      (fun i brick ->
        let brick_start, brick_end = brick in
        let min_z = Int.min brick_start.z brick_end.z in
        if min_z > 1 && get_supporter_indices brick bricks |> List.is_empty
        then (
          brick_did_fall := true;
          bricks.(i)
          <- ( { brick_start with z = brick_start.z - 1 }
             , { brick_end with z = brick_end.z - 1 } )))
      bricks
  done
;;

let bricks =
  File.lines_of "22.txt"
  |> Enum.map (fun line ->
    match String.split_on_char '~' line with
    | [ pos1; pos2 ] ->
      [ pos1; pos2 ]
      |> List.map (fun pos_string ->
        String.split_on_char ',' pos_string
        |> List.map int_of_string
        |> fun pos ->
        match pos with
        | [ x; y; z ] -> { x; y; z }
        | _ -> "Invalid 3D coordinates: " ^ pos_string |> failwith)
      |> fun pos_list ->
      (match pos_list with
       | [ pos1; pos2 ] -> pos1, pos2
       | _ -> "Invalid line:\n" ^ line |> failwith)
    | _ -> "Invalid line:\n" ^ line |> failwith)
  |> Array.of_enum
  |> tap do_physics
;;

let supporters_by_brick =
  Array.map (fun brick -> get_supporter_indices brick bricks) bricks
;;

let supportees_by_brick = Array.make (Array.length bricks) [];;

Array.iteri
  (fun i bricks ->
    List.iter
      (fun supporter_index ->
        let value = i :: supportees_by_brick.(supporter_index) in
        supportees_by_brick.(supporter_index) <- value)
      bricks)
  supporters_by_brick

let rec count_cascades running_sum brick_indices deleted_brick_indices =
  if Set.cardinal brick_indices = 0
  then running_sum
  else (
    let brick_indices', deleted_brick_indices' =
      brick_indices
      |> Set.to_list
      |> List.fold_left
           (fun (brick_indices'', deleted_brick_indices'') brick_index ->
             supportees_by_brick.(brick_index)
             |> List.fold_left
                  (fun (brick_indices''', deleted_brick_indices''') supportee_index ->
                    if (not (Set.mem supportee_index deleted_brick_indices'''))
                       && supporters_by_brick.(supportee_index)
                          |> Set.of_list
                          |> fun initial_supports ->
                          Set.diff initial_supports deleted_brick_indices'''
                          |> Set.is_empty
                    then
                      Set.add supportee_index brick_indices''', deleted_brick_indices'''
                    else brick_indices''', deleted_brick_indices''')
                  (brick_indices'', deleted_brick_indices''))
           (Set.empty, brick_indices |> Set.union deleted_brick_indices)
    in
    count_cascades
      (running_sum + Set.cardinal brick_indices')
      brick_indices'
      deleted_brick_indices')
;;

let cascade_counts =
  Array.mapi (fun i _ -> count_cascades 0 ([ i ] |> Set.of_list) Set.empty) bricks
;;

let () = cascade_counts |> Array.count_matching (( = ) 0) |> Printf.printf "Part 1: %d\n"
let () = Array.reduce ( + ) cascade_counts |> Printf.printf "Part 2: %d\n"
