#!/usr/bin/env -S opam exec -- ocaml

#use "helpers.ml"

type vector =
  { x : float
  ; y : float
  ; z : float
  }

type projectile =
  { pos : vector
  ; v : vector
  }

let hailstones =
  File.lines_of "24.txt"
  |> Enum.map (fun line ->
    Scanf.sscanf line "%f, %f, %f @ %f, %f, %f" (fun x y z x' y' z' ->
      { pos = { x; y; z }; v = { x = x'; y = y'; z = z' } }))
  |> List.of_enum
;;

let () =
  let solve_t1_t2_with_xy_only h1 h2 =
    let denom = (h1.v.x *. h2.v.y) -. (h1.v.y *. h2.v.x) in
    let x_pos_diff = h2.pos.x -. h1.pos.x in
    let y_pos_diff = h2.pos.y -. h1.pos.y in
    ( ((x_pos_diff *. h2.v.y) -. (y_pos_diff *. h2.v.x)) /. denom
    , ((x_pos_diff *. h1.v.y) -. (y_pos_diff *. h1.v.x)) /. denom )
  in
  let test_area_min, test_area_max =
    if List.length hailstones = 5 then 7., 27. else 200000000000000., 400000000000000.
  in
  List.fold_righti
    (fun i h1 count ->
      List.take i hailstones
      |> List.count_matching (fun h2 ->
        let t1, t2 = solve_t1_t2_with_xy_only h1 h2 in
        let intersection_x = h1.pos.x +. (t1 *. h1.v.x) in
        let intersection_y = h1.pos.y +. (t1 *. h1.v.y) in
        t1 >= 0.
        && (not (Float.is_special t1))
        && t2 >= 0.
        && (not (Float.is_special t2))
        && intersection_x >= test_area_min
        && intersection_x <= test_area_max
        && intersection_y >= test_area_min
        && intersection_y <= test_area_max)
      |> ( + ) count)
    hailstones
    0
  |> Printf.printf "Part 1: %d\n"
;;

let () =
  let dot { x; y; z } { x = x'; y = y'; z = z' } = (x *. x') +. (y *. y') +. (z *. z') in
  let cross { x; y; z } { x = x'; y = y'; z = z' } =
    { x = (y *. z') -. (z *. y'); y = (z *. x') -. (x *. z'); z = (x *. y') -. (y *. x') }
  in
  let vec_add v1 v2 = { x = v1.x +. v2.x; y = v1.y +. v2.y; z = v1.z +. v2.z } in
  let vec_sub v1 v2 = { x = v1.x -. v2.x; y = v1.y -. v2.y; z = v1.z -. v2.z } in
  let proj_sub h1 h2 = { pos = vec_sub h1.pos h2.pos; v = vec_sub h1.v h2.v } in
  let scalar_mult s { x; y; z } = { x = s *. x; y = s *. y; z = s *. z } in
  Unix.getpid () |> Random.init;
  (* In case we choose parallel hailstones? *)
  let h0, h1, h2 =
    match List.shuffle hailstones |> List.take 3 with
    | [ h0; h1; h2 ] -> h0, h1, h2
    | _ -> failwith "Exactly three hailstones are required"
  in
  let offset_h1 = proj_sub h1 h0 in
  let offset_h2 = proj_sub h2 h0 in
  let t1 =
    -.dot (cross offset_h1.pos offset_h2.pos) offset_h2.v
    /. dot (cross offset_h1.v offset_h2.pos) offset_h2.v
  in
  let t2 =
    -.dot (cross offset_h1.pos offset_h2.pos) offset_h1.v
    /. dot (cross offset_h1.pos offset_h2.v) offset_h1.v
  in
  let c1 = vec_add offset_h1.pos (scalar_mult t1 offset_h1.v) in
  let c2 = vec_add offset_h2.pos (scalar_mult t2 offset_h2.v) in
  let v = scalar_mult (1. /. (t2 -. t1)) (vec_sub c2 c1) in
  let offset_rock = vec_sub c1 (scalar_mult t1 v) in
  let rock = vec_add offset_rock h0.pos in
  rock.x +. rock.y +. rock.z
  |> Float.round
  |> int_of_float
  |> Printf.printf "Part 2: %d\n"
;;
