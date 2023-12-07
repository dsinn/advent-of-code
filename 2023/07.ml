#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

open Pcre
open Str
module StringMap = Map.Make (String)

let sorted_string s =
  let char_list = String.to_seq s |> Array.of_seq in
  Array.sort compare char_list;
  Array.to_seq char_list |> String.of_seq
;;

let lexize hand mapping =
  let lexicographic_map = StringMap.of_list mapping in
  let lex_rex =
    StringMap.bindings lexicographic_map
    |> List.map fst
    |> String.concat ""
    |> Printf.sprintf "[%s]"
    |> Pcre.regexp
  in
  Pcre.substitute_substrings
    ~rex:lex_rex
    ~subst:(fun substring ->
      Pcre.get_substring substring 0 |> fun s -> StringMap.find s lexicographic_map)
    hand
;;

let lex_hand_compare ?(preprocess = Fun.id) hand1 hand2 lexize =
  let hand_rexes =
    [ (* Five of a kind *)
      "(.)\\1{4}"
    ; (* Four of a kind*)
      "(.)\\1{3}"
    ; (* Full house *)
      "(.)\\1{2}(.)\\2|(.)\\3(.)\\4{2}"
    ; (* Three of a kind *)
      "(.)\\1{2}"
    ; (* Two pair *)
      "(.)\\1.?(.)\\2"
    ; (* One pair *)
      "(.)\\1"
    ; (* High card *)
      "."
    ]
    |> List.map Pcre.regexp
  in
  let sorted_hands = List.map preprocess [ hand1; hand2 ] |> List.map sorted_string in
  let type_indices =
    sorted_hands
    |> List.map (fun sorted_hand ->
      List.find_index (fun rex -> Pcre.pmatch ~rex sorted_hand) hand_rexes)
  in
  let type_diff = -compare (List.hd type_indices) (List.last type_indices) in
  if type_diff = 0 then compare (lexize hand1) (lexize hand2) else type_diff
;;

let parsed_input =
  File.lines_of "07.txt"
  |> Enum.map (fun line ->
    match String.split_on_char ' ' line with
    | [ hand; bid_string ] -> hand, int_of_string bid_string
    | _ -> failwith "Invalid input")
  |> Array.of_enum
;;

let () =
  let lexize1 hand = lexize hand [ "T", "V"; "J", "W"; "Q", "X"; "K", "Y"; "A", "Z" ] in
  let parsed_input_copy = Array.copy parsed_input in
  Array.sort
    (fun (hand1, _bid1) (hand2, _bid2) -> lex_hand_compare hand1 hand2 lexize1)
    parsed_input_copy;
  Array.to_list parsed_input_copy
  |> List.fold_lefti (fun acc i (hand, bid) -> acc + (bid * (i + 1))) 0
  |> Printf.printf "Part 1: %d\n"
;;

let () =
  let lexize2 hand = lexize hand [ "J", "."; "T", "V"; "Q", "X"; "K", "Y"; "A", "Z" ] in
  let dejokerize hand =
    String.to_seq hand
    |> Seq.fold_left
         (fun counts c ->
           if c != 'J'
           then
             Hashtbl.replace
               counts
               c
               (match Hashtbl.find_option counts c with
                | None -> 1
                | Some count -> count + 1);
           counts)
         (Hashtbl.create 0)
    |> (fun counts ->
         Hashtbl.fold
           (fun k v most_common -> if v > snd most_common then k, v else most_common)
           counts
           (' ', -1))
    |> fst
    |> String.make 1
    |> fun most_common_char ->
    Str.global_replace (Str.regexp_string "J") most_common_char hand
  in
  Array.sort
    (fun (hand1, _bid1) (hand2, _bid2) ->
      lex_hand_compare ~preprocess:dejokerize hand1 hand2 lexize2)
    parsed_input;
  Array.to_list parsed_input
  |> List.fold_lefti (fun acc i (hand, bid) -> acc + (bid * (i + 1))) 0
  |> Printf.printf "Part 2: %d\n"
;;
