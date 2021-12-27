package main

import (
	"fmt"
	"main/helper"
	"strconv"
)

var cache map[int]int

func part2cost(mass int) int {
	if cost, ok := cache[mass]; ok {
		return cost
	}
	var fuel int = mass/3 - 2
	if fuel <= 0 {
		cache[mass] = 0
	} else {
		cache[mass] = fuel + part2cost(fuel)
	}
	return cache[mass]
}

func main() {
	cache = make(map[int]int)
	var part1, part2 int = 0, 0

	for line := range helper.GetInputLineChannel() {
		mass, _ := strconv.Atoi(line)
		part1 += mass/3 - 2
		part2 += part2cost(mass)
	}

	fmt.Printf("Part 1: %d\n", part1)
	fmt.Printf("Part 2: %d\n", part2)
}
