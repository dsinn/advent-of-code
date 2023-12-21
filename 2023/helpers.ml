#use "topfind"

#require "batteries"

open Batteries

let tap f x =
  f x;
  x
;;

let read_file (filename : string) =
  Stdlib.open_in_bin filename
  |> fun channel ->
  let content = really_input_string channel (in_channel_length channel) in
  Stdlib.close_in channel;
  content |> String.trim
;;

let rec gcd a b = if Big_int.equal b Big_int.zero then a else gcd b (Big_int.modulo a b)
let lcm a b = gcd a b |> Big_int.div (Big_int.mul a b |> Big_int.abs_big_int)

let shoelace_area points =
  if List.length points < 3 then failwith "A polygon needs more than two points";
  let rec pairwise_multiply acc lst1 lst2 =
    match lst1, lst2 with
    | [], _ | _, [] -> acc
    | x1 :: xs1, x2 :: xs2 -> pairwise_multiply ((x1 * x2) + acc) xs1 xs2
  in
  let x_coords = List.map fst points in
  let y_coords = List.map snd points in
  let x_shifted = List.tl x_coords @ [ List.hd x_coords ] in
  let y_shifted = List.tl y_coords @ [ List.hd y_coords ] in
  let multiplied = pairwise_multiply 0 x_coords y_shifted in
  let subtracted = pairwise_multiply 0 x_shifted y_coords in
  Int.abs ((multiplied - subtracted) / 2)
;;
