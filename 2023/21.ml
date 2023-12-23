#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

module IntMap = Map.Make (Int)

let rec count_plots step even_count odd_count steps_to_save result to_visit visited map =
  let even_count', odd_count' =
    let addend = List.length to_visit in
    if step mod 2 = 0
    then even_count + addend, odd_count
    else even_count, odd_count + addend
  in
  let steps_to_save', result' =
    if step = List.hd steps_to_save
    then List.tl steps_to_save, IntMap.add step (even_count', odd_count') result
    else steps_to_save, result
  in
  if List.is_empty steps_to_save'
  then result'
  else (
    let to_visit' =
      List.fold_left
        (fun to_visit' (y, x) ->
          let valid_neighbours =
            List.filter
              (fun (y', x') ->
                try map.(y').(x') && not visited.(y').(x') with
                | Invalid_argument _ -> false)
              [ y - 1, x; y + 1, x; y, x - 1; y, x + 1 ]
          in
          List.iter (fun (y', x') -> visited.(y').(x') <- true) valid_neighbours;
          to_visit' @ valid_neighbours)
        []
        to_visit
    in
    count_plots
      (step + 1)
      even_count'
      odd_count'
      steps_to_save'
      result'
      to_visit'
      visited
      map)
;;

let map, start =
  let start_ref = ref (-1, -1) in
  let map =
    read_file "21.txt"
    |> String.split_on_char '\n'
    |> List.mapi (fun y line ->
      String.to_seq line
      |> Seq.mapi (fun x c ->
        match c with
        | '.' -> true
        | '#' -> false
        | 'S' ->
          start_ref := y, x;
          true
        | invalid_char -> Printf.sprintf "Invalid character %c" invalid_char |> failwith)
      |> Array.of_seq)
    |> Array.of_list
  in
  let start = !start_ref in
  if start = (-1, -1) then failwith "No start found";
  map, start
;;

let () =
  let visited = Array.make_matrix (Array.length map) (Array.length map.(0)) false in
  visited.(fst start).(snd start) <- true;
  let counts = count_plots 0 0 0 [ 64; 65; 130 ] IntMap.empty [ start ] visited map in
  IntMap.find 64 counts |> fst |> Printf.printf "Part 1: %d\n";
  (*
     Part 2 - Make massive assumptions that we couldn't in the test input:
     * All reachable plots of the initial map can be reached within 130 steps.
     * The starting points of adjacent repeating patterns in each cardinal direction are reached in exactly 131 steps.
     You can even zoom out on the input and see the "highways" that make these properties true.

     Since 26501365 = 65 + 131 * 202300, and 65 is exactly the number of steps to reach the edge of the non-repeating
     input in each cardinal direction. Let "inner" refer to the collection of plots within 65 steps, and "outer" past
     65 steps. As we draw and expand the searched area at every 65 + 131n steps,
     we see that the "inner" and "outer" plots alternate and fill in the square area of width (2n + 1).

     One complication is that whenever you move to an adjacent tile, the parity of the reachable plots switches,
     so it's a matter of identifying the patterns of how the inner vs. outer and even vs. odd copies scale.
  *)
  let target_steps = 26501365 in
  if target_steps mod 131 <> 65 then failwith "Target steps is not 65 + a multiple of 131";
  let n = (target_steps - 65) / 131 in
  let search_map_widths = 1 + (2 * n) in
  let search_map_areas = search_map_widths * search_map_widths in
  let inner_even_count, inner_odd_count = IntMap.find 65 counts in
  let total_even_count, total_odd_count = IntMap.find 130 counts in
  let outer_even_count, outer_odd_count =
    total_even_count - inner_even_count, total_odd_count - inner_odd_count
  in
  (*
     The outer copies make up just under half of the total area because the square has odd width and the inner part of
     the initial map occupies the middle. The outer copies also split perfectly between odd and even parity.
     Half of half = one quarter.
  *)
  let parity_specific_outer_copies = search_map_areas / 4 in
  (*
     Inner copies however alternate between 1 + (0 + 8 + 16 + ...) = 1^2, 3^2, 5^2, 7^2, ... of odd parity and
     0 + 4 + 12 + ... = 0^2, 2^2, 4^2, 6^2, ... of even parity, so figure out the quadratic expressions for them.
  *)
  let inner_odd_copies =
    let x = (2 * (n / 2)) + 1 in
    x * x (* 1, 1, 9, 9, 25, 25, ... *)
  in
  let inner_even_copies =
    let x = 2 * ((n / 2) + (n mod 2)) in
    x * x (* 0, 4, 4, 16, 16, 36, 36, ... *)
  in
  parity_specific_outer_copies * (outer_even_count + outer_odd_count)
  |> ( + ) (inner_odd_copies * inner_odd_count)
  |> ( + ) (inner_even_copies * inner_even_count)
  |> Printf.printf "Part 2: %d\n"
;;
