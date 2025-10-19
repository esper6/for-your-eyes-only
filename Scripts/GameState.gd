extends Node
class_name GameState

var current_scene = "Scene1"
var puzzles_solved = {}

func mark_puzzle_solved(puzzle_name):
	puzzles_solved[puzzle_name] = true

func is_puzzle_solved(puzzle_name):
	return puzzles_solved.get(puzzle_name, false)
