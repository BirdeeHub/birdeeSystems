package lib_test

import (
	"REPLACE_ME/lib"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestMapMap(t *testing.T) {
	// Test case 1: Map of strings to integers
	m1 := map[string]int{
		"one":   1,
		"two":   2,
		"three": 3,
	}
	f1 := func(k string, v int) int {
		return v * v
	}
	expected1 := map[string]int{
		"one":   1,
		"two":   4,
		"three": 9,
	}
	result1 := lib.MapMap(m1, f1)
	assert.Equal(t, expected1, result1)

	// Test case 2: Map of integers to strings
	m2 := map[int]string{
		1: "foo",
		2: "bar",
		3: "baz",
	}
	f2 := func(k int, v string) string {
		return v + v
	}
	expected2 := map[int]string{
		1: "foofoo",
		2: "barbar",
		3: "bazbaz",
	}
	result2 := lib.MapMap(m2, f2)
	assert.Equal(t, expected2, result2)

	// Test case 3: Empty map
	m3 := map[string]int{}
	f3 := func(k string, v int) int {
		return v * 2
	}
	expected3 := map[string]int{}
	result3 := lib.MapMap(m3, f3)
	assert.Equal(t, expected3, result3)
}

func TestFilterMapMap(t *testing.T) {
	// Test case 1: Filter and map a map of strings to integers
	m1 := map[string]int{
		"one":   1,
		"two":   2,
		"three": 3,
		"four":  4,
	}
	f1 := func(k string, v int) int {
		return v * v
	}
	filter1 := func(k string, v int) bool {
		return v%2 == 0
	}
	expected1 := map[string]int{
		"two":  4,
		"four": 16,
	}
	result1 := lib.FilterMapMap(m1, f1, filter1)
	assert.Equal(t, expected1, result1)

	// Test case 2: Filter and map an empty map
	m2 := map[string]int{}
	f2 := func(k string, v int) int {
		return v * 2
	}
	filter2 := func(k string, v int) bool {
		return v > 0
	}
	expected2 := map[string]int{}
	result2 := lib.FilterMapMap(m2, f2, filter2)
	assert.Equal(t, expected2, result2)
}

func TestFilterMap(t *testing.T) {
	// Test case 1: Filter a map of strings to integers
	m1 := map[string]int{
		"one":   1,
		"two":   2,
		"three": 3,
		"four":  4,
	}
	filter1 := func(k string, v int) bool {
		return v%2 == 0
	}
	expected1 := map[string]int{
		"two":  2,
		"four": 4,
	}
	result1 := lib.FilterMap(m1, filter1)
	assert.Equal(t, expected1, result1)

	// Test case 2: Filter an empty map
	m2 := map[string]int{}
	filter2 := func(k string, v int) bool {
		return v > 0
	}
	expected2 := map[string]int{}
	result2 := lib.FilterMap(m2, filter2)
	assert.Equal(t, expected2, result2)
}

func TestMapSlice(t *testing.T) {
	// Test case 1: Map a slice of integers to strings
	slice1 := []int{1, 2, 3, 4, 5}
	f1 := func(i int) string {
		return "value: " + strconv.Itoa(i)
	}
	expected1 := []string{"value: 1", "value: 2", "value: 3", "value: 4", "value: 5"}
	result1 := lib.MapSlice(slice1, f1)
	assert.Equal(t, expected1, result1)

	// Test case 2: Map an empty slice
	slice2 := []int{}
	f2 := func(i int) string {
		return "value: " + strconv.Itoa(i)
	}
	expected2 := []string{}
	result2 := lib.MapSlice(slice2, f2)
	assert.Equal(t, expected2, result2)
}

func TestFilterMapSlice(t *testing.T) {
	// Test case 1: Map and filter a slice of integers
	slice1 := []int{1, 2, 3, 4, 5}
	m1 := func(i int) string {
		return "value: " + strconv.Itoa(i)
	}
	f1 := func(i int) bool {
		return i%2 == 0
	}
	expected1 := []string{"value: 2", "value: 4"}
	result1 := lib.FilterMapSlice(slice1, m1, f1)
	assert.Equal(t, expected1, result1)

	// Test case 2: Map and filter an empty slice
	slice2 := []int{}
	m2 := func(i int) string {
		return "value: " + strconv.Itoa(i)
	}
	f2 := func(i int) bool {
		return i%2 == 0
	}
	expected2 := []string{}
	result2 := lib.FilterMapSlice(slice2, m2, f2)
	assert.Equal(t, expected2, result2)
}

func TestFilterSlice(t *testing.T) {
	// Test case 1: Filter a slice of integers
	slice1 := []int{1, 2, 3, 4, 5}
	f1 := func(i int) bool {
		return i%2 == 0
	}
	expected1 := []int{2, 4}
	result1 := lib.FilterSlice(slice1, f1)
	assert.Equal(t, expected1, result1)

	// Test case 2: Filter an empty slice
	slice2 := []int{}
	f2 := func(i int) bool {
		return i%2 == 0
	}
	expected2 := []int{}
	result2 := lib.FilterSlice(slice2, f2)
	assert.Equal(t, expected2, result2)
}
