# Reflections on AoC 2023

## Preface

It's 2023, I've just picked up all 50 stars, and I've decided to write down my personal thoughts on my experience with
Advent of Code this year, mainly to get some of this down before it erodes from my memory. This is more of a blog post
than technical documentation, the latter of which I'm way more accustomed to writing, but I don't have a blog or social
media account, so into GitHub it goes. I'm not sure whether or not I'll continue writing something like this each year,
but if I do, I'll try to do maintain this "readme" as I progress to capture the freshest thoughts.

This year, I went with learning [OCaml](https://ocaml.org/) because I enjoy object-oriented programming and already had
a good time doing functional-_ish_ programming in
[2022 with Scala](https://github.com/dsinn/advent-of-code/tree/main/2022) and part of
[2019 with Kotlin](https://github.com/dsinn/advent-of-code/tree/main/2019). (Apparently, I'm also a part of the 24.3% of
[unofficial survey](https://jeroenheijmans.github.io/advent-of-code-surveys/) respondents whose "reason for
participating" is "learn new language".) I say _ish_ because while I make some effort to follow the functional
programming (FP) paradigm, I am by no means a purist, especially since for AoC I've ended up brute-forcing something on
a large collection enough times. I have also barely spent any time using a FP language professionally,
and this admittedly _could_ be a reason for some of the OCaml lowlights ahead.

**Spoiler warning:** I get into details with specific days ahead.

## Highlights

* [Day 3](https://adventofcode.com/2023/day/3): The regexes have been whipped out early this year!
  [My implementation](https://github.com/dsinn/advent-of-code/blob/6b6656b/2023/03.ml) for each part started by
  finding numbers via regex, and then used a dynamically generated regex to determine whether the number counted
  towards the answer based on which columns the number appeared in. Reminds me of how I solved
  [2020 Day 20](https://adventofcode.com/2020/day/20), but it's far simpler than the
  [monster regex](https://github.com/dsinn/advent-of-code/blob/d95bf2b/2020/20.rb#L84-L93).
* [Day 6](https://adventofcode.com/2023/day/6): While I was disappointed that the answers in both parts could be so
  easily brute-forced, I did enjoy using the
  [quadratic formula](https://github.com/dsinn/advent-of-code/blob/6b6656b/2023/06.ml#L10-L20). Reminds me of
  [2021 Day 17](https://adventofcode.com/2021/day/17), but again far simpler than
  [what I did](https://github.com/dsinn/advent-of-code/blob/31f63b9/2021/17.py).
* [Day 9](https://adventofcode.com/2023/day/9): This is really cute in FP, and was the shortest of all my solutions
  this year. My Part 1 and Part 2 differed by
  [one callback argument](https://github.com/dsinn/advent-of-code/blob/6b6656b/2023/09.ml#L32-L37).
* [Day 14](https://adventofcode.com/2023/day/14): I made a regex do all the physics, so that satisfied my regex itch for
  the year. It was however limited to
  [moving the rocks east](https://github.com/dsinn/advent-of-code/blob/6b6656b/2023/14.ml#L22-L35), so I had to
  compensate by "rotating" the string four times a cycle.
* [Day 16](https://adventofcode.com/2023/day/16): Perhaps a prelude to Day 24, I used
  [normal vectors and dot products](https://github.com/dsinn/advent-of-code/blob/6b6656b/2023/16.ml#L68-L84) to
  calculate the reflections off of the diagonal mirrors. I'm happier with that than hardcoding the new direction for
  every mirror x direction.
* [Day 21](https://adventofcode.com/2023/day/21): The one that I am proudest of solving despite the input being crafted
  in a way that makes it possible to solve quickly. Because the map repeats infinitely, I visualized the growth
  of the search area (drawing helped a lot) and calculated the answer using only the data from the initial 131⨉131 map
  without crossing a boundary into a repeat. The tricky part was partitioning the number of reachable plots into four
  buckets: proximity to the start ⨉ step parity. Hopefully, the comments I left in the
  [main function](https://github.com/dsinn/advent-of-code/blob/6b6656b/2023/21.ml#L71) make sense.

## Lowlights

* [Day 1](https://adventofcode.com/2023/day/1): I went to the [subreddit](https://www.reddit.com/r/adventofcode/) to
  learn that `oneight` evaluates to `18` instead of `1ight`, which wasn't covered in the test case.
* [Day 5](https://adventofcode.com/2023/day/5): It's a chain of function compositions, so I tried to decompose
  everything into a single map (one [piecewise function](https://en.wikipedia.org/wiki/Piecewise)) whose intervals
  I could check against each seed range. This was a bit too backwards and messy, so I ended up just moving forward
  through each map.
* [Day 7](https://adventofcode.com/2023/day/7): I wasted time by not reading 🤦 and implemented poker rules for the
  ties, _e.g._, making `22999` win over `99222` because in poker, the three of the kind is used to break ties in a full
  house rather than the first card.
* [Day 8](https://adventofcode.com/2023/day/8): I generally like puzzles where a (subjectively) interesting math
  problem is described, but then the input is crafted such that the interesting part is removed. In this case, not only
  does each ghost only land on a `Z` node at the end of their cycle, but each cycle effectively begins immediately since
  each `Z` node connects to the same nodes as the `A` node at which the ghost started. Therefore, you can skip almost
  all modular arithmetic and go straight to computing the lowest common multiple of the periods.
* [Day 17](https://adventofcode.com/2023/day/17): It took me a long time to figure out that my answer was wrong because
  I forgot to add [one condition](https://github.com/dsinn/advent-of-code/blob/6b6656b/2023/17.ml#L68C40-L68C55) to my
  "is this move valid?" check. Admittedly, how I initiate the recursion is a bit of a hack, and so the extra condition
  is also a hack, so I deserved it and am still not too happy about the solution.

### OCaml lowlights

* **Syntax error messages were not helpful.** Something as simple as forgetting the `in` in OCaml's particular
  [let ... in](https://v2.ocaml.org/manual/bindingops.html) binding syntax, using `;` instead of `;;` or vice versa, or
  moving expressions in or out of a `let () =` context, often leads to an error message that's just "Syntax error" with
  a line number that's often far from what needs to be fixed. These pitfalls seem unique to OCaml and I spent way too
  much time digging out of them compared to most languages I've learned, whose error messages say _what_ was wrong about
  the syntax and also point to a location that's close to what needs to be fixed instead of leading you astray.
* **Type errors were extremely painful.** Whenever an expression evaluates to the wrong type, I need to know two things:
  which expression evaluates to type `a'`, and which expression expects it to be type `b'`. I was only given the former,
  but very often it's the expression expecting type `b'` that needs fixing, so I wasted an exorbitant amount of time
  scanning over the code and checking module docs. When I was writing Kotlin or Scala, I often made these mistakes too,
  but the error message details were enough to fix them quickly. Adding type hints doesn't seem to help with OCaml's
  error messages either. The simple mistake of flipping the first and second arguments can cause an error that points to
  another line, which is especially bad when the APIs are inconsistent as described below.
* **Inconsistent APIs.** Examples should suffice:
  * [Set.mem](https://v2.ocaml.org/api/Set.S.html#VALmem) and [Map.mem](https://v2.ocaml.org/api/Map.S.html#VALmem) both
    have the collection as the second argument, while [Hashtbl.mem](https://v2.ocaml.org/api/Hashtbl.html#VALmem) has it
    as the first.
  * In [Array.fold_left](https://v2.ocaml.org/api/Array.html#VALfold_left),
    [List.fold_left](https://v2.ocaml.org/api/List.html#VALfold_left),
    [Seq.fold_left](https://v2.ocaml.org/api/Seq.html#VALfold_left), and
    [BatEnum.fold](https://ocaml-batteries-team.github.io/batteries-included/hdoc2/BatEnum.html#VALfold), the
    accumulator is passed in as the first argument of the callback, while in
    [Set.fold](https://v2.ocaml.org/api/Set.S.html#VALfold) it is the second.
  * [List.filter](https://v2.ocaml.org/api/List.html#VALfilter),
    [Seq.filter](https://v2.ocaml.org/api/Seq.html#VALfilter), and
    [Set.filter](https://v2.ocaml.org/api/Set.S.html#VALfilter) exist, yet
    [Array](https://v2.ocaml.org/api/Array.html).filter does not.
    * A third-party library effectively does monkey patch this with
      [BatArray.filter](https://ocaml-batteries-team.github.io/batteries-included/hdoc2/BatArray.html#VALfilter),
      but I'm pretty sure I still found something similar even with the library installed (I should've wrote it down).
  * Nit: In order to convert from collection type A to B (_e.g.,_ List to Array), you need to find out (or remember)
    whether to use `A.to_b` or `B.from_a`. This contrasts with Scala, where I could use `.toB()` every time without
    thinking about it.
* **No early returns.** I feel like having them as guard clauses is especially valuable in FP,
  where I'm often deep in nested higher-order functions, and I made extensive use of them in previous years.
* **[Str.global_substitute](https://v2.ocaml.org/api/Str.html#VALglobal_substitute) is useless.** I'm a big regex
  lover, and I was expecting something like JavaScript's `String.prototype.replace()` with the
  [replacement](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#replacement)
  argument being a function, in order to apply transformations to each of the matched substrings in bulk.
  The problem is that the callback receives the _entire_ string it scanned rather than the substring that matches the
  pattern. Thus, if you pass a string `s` and callback `f`, and there are _n_ matches in `s`, then `f (s)` is simply
  called `n` times. If it's a [pure function](https://en.wikipedia.org/wiki/Pure_function) like it should be in FP,
  then `String.global_replace regexp s (f (s))` returns exactly the same thing. I ~~discovered~~ tested this myself
  ~~because I had only read the function signature and not the description~~ and my disappointment was so great that
  I immediately installed [PCRE-OCaml](https://github.com/mmottl/pcre-ocaml), which has what I needed in
  [Pcre.substitute_substrings](https://mmottl.github.io/pcre-ocaml/api/pcre/Pcre/index.html#val-substitute_substrings).
  * FWIW I've been writing mostly PHP and Ruby in my career, so I've used
    [preg_replace_callback](https://www.php.net/manual/en/function.preg-replace-callback.php) and
    [String#gsub](https://ruby-doc.org/3.3.0/String.html#method-i-gsub) a lot.

I would not be interested in using OCaml for AoC again until the syntax and type error messages are improved.

## Learnings

* The [shoelace formula](https://en.wikipedia.org/wiki/Shoelace_formula) can be used to compute the area of a simple
  polygon, and it looks really nice in FP too. Applies to days [10](https://adventofcode.com/2023/day/10) and
  [18](https://adventofcode.com/2023/day/18); see
  [implementation](https://github.com/dsinn/advent-of-code/blob/6b6656b/2023/helpers.ml#L23-L37).
* 3D Euclidean geometry is really interesting to think and learn about (or maybe it's just nostalgia), and I'm glad I
  didn't just call it a day after running my [Day 24](https://adventofcode.com/2023/day/24) input through something like
  [Z3](https://github.com/Z3Prover/z3) or [Mathematica](https://www.wolfram.com/mathematica/).
* [Karger's algorithm](https://en.wikipedia.org/wiki/Karger%27s_algorithm) can be used to find a minimum cut in a
  connected graph. [Implementation](https://github.com/dsinn/advent-of-code/blob/6b6656b/2023/25.ml#L5-L24) on
  [Day 25](https://adventofcode.com/2023/day/25).
  * I learned about the [max-flow min-cut theorem](https://en.wikipedia.org/wiki/Max-flow_min-cut_theorem) nearly 15
    years ago, but that requires a source and a sink, which we don't have on Day 25.
* A bit of knowledge of [Mermaid diagrams](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams#creating-mermaid-diagrams)
  can help visualize graphs, which I did on Day 25.
* OCaml
  * Error stack traces aren't displayed by default, so I have `export OCAMLRUNPARAM=b`
    ([runtime docs](https://v2.ocaml.org/manual/runtime.html)) in my shell profile.
  * The [Scanf](https://v2.ocaml.org/api/Scanf.html) module is quite nice, and I discovered it on Day 20 thanks to
    GitHub Copilot.
  * [Batteries](https://github.com/ocaml-batteries-team/batteries-included) proved to be useful many times.
    * However, their API doesn't always match OCaml's. For example,
      [Set.inter](https://v2.ocaml.org/api/Set.S.html#VALinter) corresponds to
      [BatSet.intersect](https://ocaml-batteries-team.github.io/batteries-included/hdoc2/BatSet.html#VALintersect)
      instead of `BatSet.inter`, and there is no alias.

## Other remarks

* This was my first year using generative AI, namely [GitHub Copilot](https://github.com/features/copilot) and ChatGPT,
  and while I specifically avoided using large swaths of code, I found them both to be good for learning new things.
  * Copilot was generally only good for saving keystrokes by autocompleting syntax and method calls, but occasionally
    it would generate some code that I was unfamiliar with and worth learning about (_e.g._, `Scanf` mentioned above).
  * ChatGPT was good when I was stuck, as it sometimes just served as a rubber duck as I was working something out, and
    other times it name-dropped something with which I wasn't familiar, but that I could then read up on and implement
    myself (_i.e._, the aforementioned shoelace formula and Karger's algorithm).
* [Day 12](https://adventofcode.com/2023/day/12): I kept thinking about a combinatorial approach that's similar to
  [2020 Day 10](https://adventofcode.com/2020/day/10) and
  [my solution](https://github.com/dsinn/advent-of-code/blob/d593401/2020/10.rb) for it, but ultimately I couldn't do it
  and went with the [recurse & memoize](https://github.com/dsinn/advent-of-code/blob/6b6656b/2023/12.ml) strategy.
  * My initial solution was to match every possible combination against a regex. It was very slow, but I was amused that
    it produced one of my all-time longest regexes:

    <details>
      <summary>Long regex</summary>

      ```
      ^\.*#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.+#{4}\.+#{1}\.+#{1}\.*$
      ```
    </details>
* Two years in a row, graph traversal is the recurring theme instead of variations on
  [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).
