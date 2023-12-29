#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

let rotate_clockwise s =
  let total_length = String.length s in
  let width = String.index_from s 0 '\n' + 1 in
  let height = (total_length + 1) / width in
  let buffer = Buffer.create (total_length + 1) in
  let row_starts = List.range (height - 1) `Downto 0 |> List.map (fun y -> y * width) in
  for x = 0 to width - 2 do
    List.iter (fun row_start -> Buffer.add_char buffer s.[row_start + x]) row_starts;
    Buffer.add_char buffer '\n'
  done;
  Buffer.contents buffer |> String.trim
;;

let move_rocks_east map =
  let rex = Pcre.regexp "O+\\.[O.]*" in
  Pcre.substitute_substrings
    ~rex
    ~subst:(fun substring ->
      let s = Pcre.get_substring substring 0 in
      String.to_seq s
      |> Seq.fold_left
           (fun rock_count ch -> (if ch = 'O' then 1 else 0) |> ( + ) rock_count)
           0
      |> fun rock_count ->
      String.repeat "." (String.length s - rock_count) ^ String.repeat "O" rock_count)
    map
;;

let calc_load_on_right_side map =
  let width = String.index_from map 0 '\n' + 1 in
  Pcre.exec_all ~rex:(Pcre.regexp "O") map
  |> Array.fold_left
       (fun sum substring ->
         (Pcre.get_substring_ofs substring 0 |> fst) mod width |> ( + ) (sum + 1))
       0
;;

let () =
  let rec run_cycles counter times map_to_counter counter_to_map_ref map =
    if counter = times
    then map
    else (
      let new_counter = counter + 1 in
      let new_map =
        Enum.fold
          (fun map _ -> rotate_clockwise map |> move_rocks_east)
          map
          (Enum.range 1 ~until:4)
      in
      if Hashtbl.mem map_to_counter new_map
      then (
        let period = new_counter - Hashtbl.find map_to_counter new_map in
        let remaining = (times - new_counter) mod period in
        let target = new_counter - period + remaining in
        !(Hashtbl.find counter_to_map_ref target))
      else (
        Hashtbl.add map_to_counter new_map new_counter;
        Hashtbl.add counter_to_map_ref new_counter (ref new_map);
        run_cycles new_counter times map_to_counter counter_to_map_ref new_map))
  in
  read_file "14.txt"
  |> tap (fun map ->
    rotate_clockwise map
    |> move_rocks_east
    |> calc_load_on_right_side
    |> Printf.printf "Part 1: %d\n")
  |> run_cycles 0 1000000000 (Hashtbl.create 0) (Hashtbl.create 0)
  |> rotate_clockwise (* One more time so that north is on the right side of the string *)
  |> calc_load_on_right_side
  |> Printf.printf "Part 2: %d\n"
;;
