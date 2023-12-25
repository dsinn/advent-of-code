#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

let rec calc_best_heat_loss
  to_visit
  best_result_map
  heat_loss_map
  fold_callback
  result_finder
  =
  if List.is_empty to_visit
  then (
    let height = Array.length best_result_map in
    let width = Array.length best_result_map.(0) in
    result_finder best_result_map.(height - 1).(width - 1))
  else (
    let to_visit' =
      List.fold_left
        (fun to_visit (y, x, dir, streak) ->
          [ y, x + 1; y - 1, x; y, x - 1; y + 1, x ]
          |> List.fold_lefti
               (fun to_visit dir' (y', x') ->
                 try
                   let heat_loss =
                     best_result_map.(y).(x).(dir).(streak) + heat_loss_map.(y').(x')
                   in
                   let streak' = if dir = dir' then streak + 1 else 0 in
                   fold_callback y' x' dir' streak' dir streak heat_loss to_visit
                 with
                 | Invalid_argument _ -> to_visit)
               to_visit)
        []
        to_visit
    in
    calc_best_heat_loss to_visit' best_result_map heat_loss_map fold_callback result_finder)
;;

let heat_loss_map =
  read_file "17.txt"
  |> String.split_on_char '\n'
  |> List.map (fun line ->
    String.to_seq line |> Seq.map (fun c -> Char.code c - 48) |> Array.of_seq)
  |> Array.of_list
;;

let height = Array.length heat_loss_map
let width = Array.length heat_loss_map.(0)

let () =
  let best_result_map =
    Array.init height (fun _ ->
      Array.init width (fun _ ->
        Array.init 4 (fun _dir ->
          (* The "streak" value goes from 0-2 instead of 1-3 just to play nicely with 0-indexing *)
          Array.init 3 (fun _streak -> Int.max_num))))
  in
  (* Chose `1` as the initial direction because you can't go further up at the top-left corner *)
  let init_dir, init_streak = 1, 0 in
  best_result_map.(0).(0).(init_dir).(init_streak) <- 0;
  calc_best_heat_loss
    [ 0, 0, init_dir, init_streak ]
    best_result_map
    heat_loss_map
    (fun y' x' dir' streak' dir _streak heat_loss to_visit ->
      if heat_loss < best_result_map.(y').(x').(dir').(streak')
         && streak' < 3
         && (Int.abs (dir' - dir) <> 2 || y' + x' <= 1)
      then (
        List.range streak' `To 2
        |> List.iter (fun z' ->
          best_result_map.(y').(x').(dir').(z')
          <- Int.min heat_loss best_result_map.(y').(x').(dir').(z'));
        (y', x', dir', streak') :: to_visit)
      else to_visit)
    (Array.fold_left (fun min row -> Int.min min (Array.min row)) Int.max_num)
  |> Printf.printf "Part 1: %d\n"
;;

let () =
  let best_result_map =
    Array.init height (fun _ ->
      Array.init width (fun _ ->
        Array.init 4 (fun _dir -> Array.init 10 (fun _streak -> Int.max_num))))
  in
  (* With this setup, the ultra crucible needs to "turn" at the first step, so a streak of 0 won't work this time *)
  let init_dir, init_streak = 1, 9 in
  best_result_map.(0).(0).(init_dir).(init_streak) <- 0;
  calc_best_heat_loss
    [ 0, 0, init_dir, init_streak ]
    best_result_map
    heat_loss_map
    (fun y' x' dir' streak' dir streak heat_loss to_visit ->
      if heat_loss < best_result_map.(y').(x').(dir').(streak')
         && ((dir = dir' && streak < 9) || (dir <> dir' && streak >= 3))
         && (Int.abs (dir' - dir) <> 2 || y' + x' <= 1)
      then (
        best_result_map.(y').(x').(dir').(streak') <- heat_loss;
        (y', x', dir', streak') :: to_visit)
      else to_visit)
    (Array.fold_left
       (fun min row ->
         (* Discard results where the streak was too short at the end *)
         Int.min min (Array.sub row 3 7 |> Array.min))
       Int.max_num)
  |> Printf.printf "Part 2: %d\n"
;;
