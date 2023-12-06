#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

open Str

let race_product races =
  List.fold_left
    (fun product (time, distance_to_beat) ->
      (* We're finding all the x such at x * (x - time) > distance *)
      (* Use the quadratic formula to solve for x *)
      let time_f = float_of_int time in
      (time_f
       -. Float.sqrt (Float.pow time_f 2.0 -. (4.0 *. (distance_to_beat |> float_of_int)))
      )
      /. 2.0
      (* +1 and floor in case of a tie *)
      |> (fun x -> x +. 1.0 |> floor |> int_of_float)
      (* Strip the non-winning left and right edges of the interval [0, time] *)
      |> (fun x -> time - (2 * x))
      |> ( + ) 1 (* This is an inclusive range *)
      |> ( * ) product)
    1
    races
;;

let () =
  let races =
    match
      File.lines_of "06.txt"
      |> Enum.map (fun line ->
        Str.split (Str.regexp ": *") line
        |> List.last
        |> Str.split (Str.regexp " +")
        |> List.map int_of_string)
      |> List.of_enum
    with
    | [ times; distances ] -> List.combine times distances
    | _ -> failwith "Did not find exactly two lines in the input file"
  in
  race_product races |> Printf.printf "Part 1: %d\n"
;;

let () =
  let time, distance =
    match
      File.lines_of "06.txt"
      |> Enum.map (fun line ->
        Str.global_replace (Str.regexp "[^0-9]") "" line |> int_of_string)
      |> List.of_enum
    with
    | [ time; distance ] -> time, distance
    | _ -> failwith "Did not find exactly two lines in the input file"
  in
  race_product [ time, distance ] |> Printf.printf "Part 2: %d\n"
;;
