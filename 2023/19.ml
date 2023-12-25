#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

#require "pcre"

open Pcre
module CharMap = Map.Make (Char)
module StringMap = Map.Make (String)

type rule =
  { category : char
  ; op : int -> int -> bool
  ; op_char : char (* For the possible quirk described further down *)
  ; value : int
  ; destination : string
  }

type workflow =
  { rules : rule array
  ; default : string
  }

let (workflows : workflow StringMap.t), (parts : int CharMap.t list) =
  read_file "19.txt"
  |> Str.split (Str.regexp "\n\n")
  |> fun sections ->
  match sections with
  | [ workflows_string; parts_string ] ->
    ( String.split_on_char '\n' workflows_string
      |> List.map (fun line ->
        let workflow_name = String.index line '{' |> String.sub line 0 in
        let rules =
          Pcre.exec_all ~pat:"([a-z])([<>])(\\d+):([AR]|[a-z]+)" line
          |> Array.map (fun substrings ->
            let category_string, op_string, value_string, destination =
              match List.range 1 `To 4 |> List.map (Pcre.get_substring substrings) with
              | [ a; b; c; d ] -> a, b, c, d
              | _ -> failwith "This is impossible"
            in
            let op =
              match op_string with
              | ">" -> ( > )
              | "<" -> ( < )
              | invalid_op -> failwith ("Invalid operator: " ^ invalid_op)
            in
            { category = category_string.[0]
            ; op
            ; op_char = op_string.[0]
            ; value = int_of_string value_string
            ; destination
            })
        in
        let last_comma_index = String.rindex line ',' in
        let default =
          String.sub
            line
            (last_comma_index + 1)
            (String.length line - last_comma_index - 2)
        in
        workflow_name, { rules; default })
      |> StringMap.of_list
    , String.split_on_char '\n' parts_string
      |> List.map (fun part_line ->
        String.length part_line - 2
        |> String.sub part_line 1
        |> String.split_on_char ','
        |> List.fold_left
             (fun categories category_string ->
               match String.split_on_char '=' category_string with
               | [ category; value_string ] ->
                 CharMap.add category.[0] (int_of_string value_string) categories
               | _ -> failwith ("Invalid category string " ^ category_string))
             CharMap.empty) )
  | _ -> failwith "Invalid input"
;;

let () =
  let rec is_acceptable part workflow_name workflows =
    match workflow_name with
    | "A" -> true
    | "R" -> false
    | _ ->
      let workflow = StringMap.find workflow_name workflows in
      (match
         Array.find_opt
           (fun rule -> rule.op (CharMap.find rule.category part) rule.value)
           workflow.rules
       with
       | Some rule -> is_acceptable part rule.destination workflows
       | None -> is_acceptable part workflow.default workflows)
  in
  List.fold_left
    (fun sum part ->
      (if is_acceptable part "in" workflows
       then
         CharMap.bindings part
         |> List.fold_left (fun rating (_, value) -> rating + value) 0
       else 0)
      |> ( + ) sum)
    0
    parts
  |> Printf.printf "Part 1: %d\n"
;;

type range =
  { min : int
  ; max : int
  }

let () =
  let rec count_possibilities
    : string -> range CharMap.t -> workflow StringMap.t -> Big_int.t
    =
    fun workflow_name ranges workflows ->
    match workflow_name with
    | "A" ->
      CharMap.bindings ranges
      |> List.fold_left
           (fun product (_category, range) ->
             range.max - range.min + 1 |> Big_int.of_int |> Big_int.mul product)
           Big_int.one
    | "R" -> Big_int.zero
    | _ ->
      let workflow = StringMap.find workflow_name workflows in
      let workflow_sum, default_ranges =
        workflow.rules
        |> Array.fold_left
             (fun (workflow_sum, rolling_ranges) rule ->
               let range = CharMap.find rule.category rolling_ranges in
               (match rule.op_char with
                (*
                   OCaml quirk with matching operators?
                   If I have `match rule.op` with `| (<) -> ...` and `| (>) -> ...`,
                   the latter will never match and even the compiler will warn me about it.
                *)
                | '<' ->
                  ( { range with max = Int.min (rule.value - 1) range.max }
                  , { range with min = rule.value } )
                | '>' ->
                  ( { range with min = Int.max (rule.value + 1) range.min }
                  , { range with max = rule.value } )
                | invalid_op_char ->
                  String.make 1 invalid_op_char |> ( ^ ) "Invalid operator " |> failwith)
               |> fun (rule_match_range, rule_mismatch_range) ->
               if rule_match_range.min > rule_match_range.max
               then Big_int.zero, rolling_ranges
               else (
                 let rule_match_ranges =
                   CharMap.add rule.category rule_match_range rolling_ranges
                 in
                 let rule_mismatch_ranges =
                   CharMap.add rule.category rule_mismatch_range rolling_ranges
                 in
                 ( count_possibilities rule.destination rule_match_ranges workflows
                 , rule_mismatch_ranges )
                 |> fun (rule_sum, new_ranges) ->
                 Big_int.add workflow_sum rule_sum, new_ranges))
             (Big_int.zero, ranges)
      in
      Big_int.add
        workflow_sum
        (count_possibilities workflow.default default_ranges workflows)
  in
  count_possibilities
    "in"
    ([ 'x', { min = 1; max = 4000 }
     ; 'm', { min = 1; max = 4000 }
     ; 'a', { min = 1; max = 4000 }
     ; 's', { min = 1; max = 4000 }
     ]
     |> CharMap.of_list)
    workflows
  |> Big_int.to_string
  |> Printf.printf "Part 2: %s\n"
;;
