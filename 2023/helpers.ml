#use "topfind"

#require "batteries"

open Batteries

let tap f x =
  f x;
  x
;;

let yield_self f x = f x

let read_file (filename : string) =
  Stdlib.open_in_bin filename
  |> yield_self (fun channel ->
    let content = really_input_string channel (in_channel_length channel) in
    Stdlib.close_in channel;
    content |> String.trim)
;;
