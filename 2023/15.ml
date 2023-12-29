#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

let () =
  let hash s =
    String.to_seq s
    |> Seq.fold_left
         (fun current_value c -> current_value + Char.code c |> fun x -> x * 17 mod 256)
         0
  in
  read_file "15.txt"
  |> String.split_on_char ','
  |> tap (fun steps ->
    List.fold_left (fun sum step -> sum + hash step) 0 steps
    |> Printf.printf "Part 1: %d\n")
  |> fun steps ->
  let boxes : (string * int) list array = Array.make 256 [] in
  List.iter
    (fun step ->
      let substrings = Pcre.exec ~pat:"^([^-=]++)([-=])(\\d*)$" step in
      let [ lens_label; operation ] = List.map (Pcre.get_substring substrings) [ 1; 2 ] in
      let box_label = hash lens_label in
      boxes.(box_label)
      <- (if operation = "-"
          then
            List.remove_if
              (fun (installed_lens_label, _) -> lens_label = installed_lens_label)
              boxes.(box_label)
          else (
            let focal_length = Pcre.get_substring substrings 3 |> int_of_string in
            try
              List.findi
                (fun _ (installed_lens_label, _) -> lens_label = installed_lens_label)
                boxes.(box_label)
              |> fst
              |> fun lens_index ->
              List.modify_at
                lens_index
                (fun _ -> lens_label, focal_length)
                boxes.(box_label)
            with
            | Not_found -> boxes.(box_label) @ [ lens_label, focal_length ])))
    steps;
  Array.fold_lefti
    (fun total_power box_label box ->
      List.fold_lefti
        (fun lens_power lens_index (lens_label, focal_length) ->
          (lens_index + 1) * focal_length |> ( + ) lens_power)
        0
        box
      |> ( * ) (box_label + 1)
      |> ( + ) total_power)
    0
    boxes
  |> Printf.printf "Part 2: %d\n"
;;
