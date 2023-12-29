#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

let count_winners line =
  let winning_numbers, my_numbers =
    Str.split (Str.regexp " *[:|] *") line
    |> List.tl
    |> List.map (fun list_string ->
      Str.split (Str.regexp " +") list_string |> List.map int_of_string |> Set.of_list)
    |> fun list -> List.hd list, List.nth list 1
  in
  Set.intersect winning_numbers my_numbers |> Set.cardinal
;;

let () =
  File.lines_of "04.txt"
  |> Enum.fold
       (fun sum line ->
         count_winners line
         |> (fun count -> if count > 0 then 1 lsl (count - 1) else 0)
         |> ( + ) sum)
       0
  |> Printf.printf "Part 1: %d\n"
;;

let () =
  let winners_by_card =
    File.lines_of "04.txt" |> Enum.map (fun line -> count_winners line) |> Array.of_enum
  in
  let rec count_copies winners_by_card i copies_by_card =
    if Hashtbl.mem copies_by_card i
    then Hashtbl.find copies_by_card i
    else (
      let winners = winners_by_card.(i) in
      let result =
        BatEnum.range (i + 1) ~until:(i + winners)
        |> BatEnum.fold
             (fun sum j ->
               let cascades = count_copies winners_by_card j copies_by_card in
               Hashtbl.replace copies_by_card j cascades;
               sum + cascades)
             0
      in
      Hashtbl.replace copies_by_card i result;
      winners + result)
  in
  let copies_by_card = Hashtbl.create 0 in
  let card_count = Array.length winners_by_card in
  BatEnum.range 0 ~until:(card_count - 1)
  |> BatEnum.fold (fun sum i -> sum + count_copies winners_by_card i copies_by_card) 0
  |> ( + ) card_count
  |> Printf.printf "Part 2: %d\n"
;;
