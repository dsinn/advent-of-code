#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

module CharMap = Map.Make (Char)

let () =
  let rec energize ?(energized = Array.make 0 (Array.make 0 Set.empty)) y x dir beams =
    (* Hooray, using math! *)
    let normals : (float * float) list CharMap.t =
      [ '/', [ Float.invsqrt2, Float.invsqrt2; -.Float.invsqrt2, -.Float.invsqrt2 ]
      ; '|', [ 0., -1.; 0., 1. ]
      ; '\\', [ -.Float.invsqrt2, Float.invsqrt2; Float.invsqrt2, -.Float.invsqrt2 ]
      ; '-', [ -1., 0.; 1., 0. ]
      ]
      |> CharMap.of_list
    in
    let energized =
      if Array.length energized = 0
      then Array.make_matrix (Array.length beams) (Array.length beams.(0)) Set.empty
      else energized
    in
    try
      if Set.mem dir energized.(y).(x)
      then energized
      else (
        energized.(y).(x) <- Set.add dir energized.(y).(x);
        let y_offset, x_offset = dir in
        let beam = beams.(y).(x) in
        if beam = '.'
        then
          energize
            (y + Float.round_to_int y_offset)
            (x + Float.round_to_int x_offset)
            dir
            beams
            ~energized
        else (
          let dot_products =
            CharMap.find beam normals
            |> List.map (fun (n_y, n_x) -> (n_y *. y_offset) +. (n_x *. x_offset))
          in
          if List.for_all (( = ) 0.) dot_products
          then
            (* Pointy end, so keep going *)
            energize
              (y + Float.round_to_int y_offset)
              (x + Float.round_to_int x_offset)
              dir
              beams
              ~energized
          else if List.exists (( = ) 1.) dot_products
                  && List.exists (( = ) (-1.)) dot_products
          then (
            (* Flat side, so split *)
            [ x_offset, y_offset; -.x_offset, -.y_offset ]
            |> List.iter (fun new_dir ->
              let new_y_offset, new_x_offset = new_dir in
              energize
                (y + Float.round_to_int new_y_offset)
                (x + Float.round_to_int new_x_offset)
                new_dir
                beams
                ~energized
              |> ignore);
            energized)
          else (
            (* Diagonal, so reflect *)
            (* There are two normals, so choose the correct one (negative) *)
            let normal_index, dot_product =
              List.findi (fun _ dot_product -> dot_product < 0.) dot_products
            in
            let normal_coeff = -2. *. dot_product in
            let n_y, n_x = List.nth (CharMap.find beam normals) normal_index in
            let new_y_offset, new_x_offset =
              ( y_offset +. (normal_coeff *. n_y) |> Float.round
              , x_offset +. (normal_coeff *. n_x) |> Float.round )
            in
            energize
              (y + Float.round_to_int new_y_offset)
              (x + Float.round_to_int new_x_offset)
              (new_y_offset, new_x_offset)
              beams
              ~energized)))
    with
    | Invalid_argument _ -> energized
  in
  let count_energized_tiles energized =
    Array.fold_left
      (fun count row ->
        Array.count_matching (fun set -> not (Set.is_empty set)) row + count)
      0
      energized
  in
  let beams =
    File.lines_of "16.txt"
    |> Enum.map (fun line -> String.to_seq line |> Array.of_seq)
    |> Array.of_enum
  in
  let () =
    energize 0 0 (0., 1.) beams |> count_energized_tiles |> Printf.printf "Part 1: %d\n"
  in
  let () =
    let height = Array.length beams in
    let width = Array.length beams.(0) in
    List.range 0 `To (height - 1)
    |> List.fold_left
         (fun max y ->
           [ max
           ; energize y 0 (0., 1.) beams |> count_energized_tiles
           ; energize y (width - 1) (0., -1.) beams |> count_energized_tiles
           ]
           |> List.max)
         0
    |> (fun max ->
         List.range 0 `To (width - 1)
         |> List.fold_left
              (fun max x ->
                [ max
                ; energize 0 x (1., 0.) beams |> count_energized_tiles
                ; energize (height - 1) x (-1., 0.) beams |> count_energized_tiles
                ]
                |> List.max)
              max)
    |> Printf.printf "Part 2: %d\n"
  in
  ()
;;
