#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

let rec karger_edge_cuts vertex_set edge_set merges =
  if Set.cardinal vertex_set <= 2
  then edge_set
  else (
    (* Work around Set.choose being determistic *)
    let u, v =
      edge_set |> Set.to_list |> fun lst -> List.length lst |> Random.int |> List.nth lst
    in
    let u', v' = Hashtbl.find_default merges u u, Hashtbl.find_default merges v v in
    Hashtbl.bindings merges
    |> List.iter (fun (w, x) -> if v' = x then Hashtbl.replace merges w u');
    Hashtbl.replace merges v' u';
    karger_edge_cuts
      (Set.remove v' vertex_set)
      (Set.filter
         (fun (w, x) ->
           Hashtbl.find_default merges w w <> Hashtbl.find_default merges x x)
         edge_set)
      merges)
;;

let rec count_connected_vertices count to_visit visited edge_hash =
  let count' = count + List.length to_visit in
  if List.is_empty to_visit
  then count'
  else (
    let to_visit', visited' =
      List.fold_left
        (fun (to_visit', visited') v ->
          List.fold_left
            (fun (to_visit'', visited'') neighbour ->
              if Set.mem neighbour visited''
              then to_visit'', visited''
              else neighbour :: to_visit'', Set.add neighbour visited'')
            (to_visit', visited')
            (Hashtbl.find edge_hash v))
        ([], visited)
        to_visit
    in
    count_connected_vertices count' to_visit' visited' edge_hash)
;;

exception Break of (string * string) Set.t

let () =
  let edge_set =
    File.lines_of "25.txt"
    |> Enum.fold
         (fun set_list line ->
           match String.split_on_char ':' line with
           | [ key; value_strings ] ->
             value_strings
             |> String.trim
             |> String.split_on_char ' '
             |> List.fold_left
                  (fun set_list' value_string ->
                    set_list' @ [ key, value_string; value_string, key ])
                  set_list
           | _ -> failwith "Invalid mapping")
         []
    |> Set.of_list
  in
  let edge_hash = Hashtbl.create (Set.cardinal edge_set) in
  Set.iter
    (fun (u, v) ->
      v :: Hashtbl.find_default edge_hash u [] |> Hashtbl.replace edge_hash u)
    edge_set;
  let vertex_set = Set.fold (fun (u, _) set -> Set.add u set) edge_set Set.empty in
  let vertex_count = Set.cardinal vertex_set in
  "Warning: Not only do I use a Monte Carlo algorithm,\n"
  ^ "but my implementation is probably bugged so it only has a small chance of working.\n"
  ^ "This will just keep looping until it finds the right answer, which took me minutes."
  |> print_endline;
  Unix.getpid () |> (* Hehe *) Random.init;
  let edges_to_cut =
    try
      Enum.range 1
      |> Enum.iter (fun iter ->
        let edges_to_cut =
          karger_edge_cuts vertex_set edge_set (Hashtbl.create vertex_count)
        in
        if Set.cardinal edges_to_cut = 6
        then (
          Printf.printf "\nFound a cut with three wires after %d attempts.\n" iter;
          raise (Break edges_to_cut));
        print_string ".";
        if iter mod 80 = 0 then print_newline ();
        flush stdout);
      Set.empty
    with
    | Break result -> result
  in
  Set.iter
    (fun (u, v) ->
      List.remove (Hashtbl.find edge_hash u) v |> Hashtbl.replace edge_hash u)
    edges_to_cut;
  let starting_vertex = Set.choose vertex_set in
  count_connected_vertices
    0
    [ starting_vertex ]
    ([ starting_vertex ] |> Set.of_list)
    edge_hash
  |> (fun count -> count * (Set.cardinal vertex_set - count))
  |> Printf.printf "Answer: %d\n"
;;
