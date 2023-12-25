#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

type pulse_amplitude =
  | High
  | Low

type pulse =
  { (* Wanted to use comm_module but we got a catch-22 because its definition depends on `pulse` *)
    source : string
  ; destination : string
  ; amplitude : pulse_amplitude
  }

let module_type_simple = "simple"
let module_type_flip_flop = "flip-flop"
let module_type_conjunction = "conjunction"

class virtual comm_module (name : string) (destinations : string list) =
  object (self)
    val name = name
    val destinations = destinations
    method name : string = name
    method destinations : string list = destinations
    method virtual handle_pulse : pulse -> pulse list

    method
      virtual module_type
      : string (* Workaround for OCaml's lack of a type checking API *)
  end

class simple_module name destinations =
  object (self)
    inherit comm_module name destinations

    method handle_pulse pulse =
      List.map
        (fun destination -> { source = name; destination; amplitude = pulse.amplitude })
        destinations

    method module_type = module_type_simple
  end

class flip_flop name destinations =
  object (self)
    inherit comm_module name destinations
    val mutable state = false

    method handle_pulse pulse =
      if pulse.amplitude = High
      then []
      else (
        state <- not state;
        List.map
          (fun destination ->
            { source = name; destination; amplitude = (if state then High else Low) })
          destinations)

    method module_type = module_type_flip_flop
  end

class conjunction ?(sources : string list = []) name destinations =
  object (self)
    inherit comm_module name destinations

    val prev_pulses =
      List.length sources
      |> Hashtbl.create
      |> tap (fun prev_pulses ->
        List.iter (fun source -> Hashtbl.add prev_pulses source Low) sources)

    method handle_pulse pulse =
      Hashtbl.replace prev_pulses pulse.source pulse.amplitude;
      (if Hashtbl.values prev_pulses |> Enum.for_all (( = ) High) then Low else High)
      |> fun amplitude ->
      List.map (fun destination -> { source = name; destination; amplitude }) destinations

    method module_type = module_type_conjunction
  end

module StringMap = Map.Make (String)

let get_module_map_from_file file =
  (* The number of lines in my input file ¯\_(ツ)_/¯ *)
  let dest_input_map = Hashtbl.create 58 in
  let (non_conj_modules : comm_module list), (conj_mappings : (string * string list) list)
    =
    File.lines_of file
    |> Enum.fold
         (fun (non_conj_modules, conj_mappings) line ->
           Scanf.sscanf line "%s -> %[^'\n']" (fun full_source destinations_string ->
             let source_name = String.sub full_source 1 (String.length full_source - 1) in
             let destinations = Str.split (Str.regexp ", ") destinations_string in
             List.iter
               (fun destination ->
                 Hashtbl.find_default dest_input_map destination []
                 |> fun lst ->
                 source_name :: lst |> Hashtbl.replace dest_input_map destination)
               destinations;
             if full_source = "broadcaster"
             then
               ( new simple_module full_source destinations :: non_conj_modules
               , conj_mappings )
             else (
               match full_source.[0] with
               | '%' ->
                 new flip_flop source_name destinations :: non_conj_modules, conj_mappings
               | '&' -> non_conj_modules, (source_name, destinations) :: conj_mappings
               | invalid_module ->
                 Printf.sprintf "Unknown module symbol '%c'" invalid_module |> failwith)))
         ([], [])
  in
  List.map
    (fun (name, destinations) ->
      let sources = Hashtbl.find dest_input_map name in
      new conjunction ~sources name destinations)
    conj_mappings
  |> List.append non_conj_modules
  |> fun lst ->
  ( new simple_module "button" [ "broadcaster" ]
    (* Since the button press counts as a pulse *)
    :: lst
    |> List.map (fun comm_module -> comm_module#name, comm_module)
    |> StringMap.of_list
  , dest_input_map )
;;

let push_button ?(pulse_callback = fun _ -> ()) module_map =
  let rec handle_pulses pulses (low_pulses, high_pulses) module_map =
    if List.is_empty pulses
    then low_pulses, high_pulses
    else (
      let pulses' =
        List.fold_left
          (fun pulses' pulse ->
            pulse_callback pulse;
            match StringMap.find_opt pulse.destination module_map with
            | Some comm_module -> comm_module#handle_pulse pulse |> List.append pulses'
            | None -> pulses')
          []
          pulses
      in
      let low_matches = List.count_matching (fun pulse -> pulse.amplitude = Low) pulses in
      let low_pulses' = low_pulses + low_matches in
      let high_pulses' = high_pulses + (List.length pulses - low_matches) in
      handle_pulses pulses' (low_pulses', high_pulses') module_map)
  in
  handle_pulses
    [ { source = "button"; destination = "broadcaster"; amplitude = Low } ]
    (0, 0)
    module_map
;;

let () =
  let module_map, _ = get_module_map_from_file "20.txt" in
  List.range 1 `To 1000
  |> List.fold_left
       (fun (low_pulses, high_pulses) _ ->
         push_button module_map
         |> fun (low_pulses', high_pulses') ->
         low_pulses + low_pulses', high_pulses + high_pulses')
       (0, 0)
  |> fun (low_pulses, high_pulses) ->
  Printf.printf "Low: %d, High: %d\n" low_pulses high_pulses;
  low_pulses * high_pulses |> Printf.printf "Part 1: %d\n"
;;

exception Break

let () =
  let rec get_conj_deps module_name amplitude module_map dest_input_map =
    let direct_deps =
      Hashtbl.find dest_input_map module_name
      |> List.map (fun module_name -> StringMap.find module_name module_map)
    in
    if List.for_all
         (fun dep_module -> dep_module#module_type = module_type_conjunction)
         direct_deps
    then (
      let amplitude' =
        match amplitude with
        | Low -> High
        | High -> Low
      in
      List.fold_left
        (fun deps conj_module ->
          deps @ get_conj_deps conj_module#name amplitude' module_map dest_input_map)
        []
        direct_deps)
    else [(module_name, amplitude)]
  in
  let module_map, dest_input_map = get_module_map_from_file "20.txt" in
  let rx_deps =
    get_conj_deps "rx" High module_map dest_input_map |> StringMap.of_list
  in
  let rx_dep_count = StringMap.cardinal rx_deps in
  let conj_periods = Hashtbl.create rx_dep_count in
  try
    Enum.range 1
    |> Enum.iter (fun presses ->
      push_button
        ~pulse_callback:(fun pulse ->
          if StringMap.mem pulse.source rx_deps
             && StringMap.find pulse.source rx_deps = pulse.amplitude
             && not (Hashtbl.mem conj_periods pulse.source)
          then (
            Printf.printf "Period of %s = %d\n" pulse.source presses;
            Hashtbl.add conj_periods pulse.source presses;
          )
          else ())
        module_map
      |> ignore;
      (* @TODO Fix this ending condition as soon as one level of dependencies is satisfied *)
      if rx_dep_count = Hashtbl.length conj_periods
      then (
        Hashtbl.values conj_periods
        |> Enum.fold
             (fun result period -> Big_int.big_int_of_int period |> lcm result)
             Big_int.one
        |> Big_int.to_string
        |> Printf.printf "Part 2: %s\n";
        raise Break))
  with
  | Break -> ()
;;
