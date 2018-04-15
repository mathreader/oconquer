type t = Empty | Mountain | Fort | City of int

exception BadTileInput

let num_of_soldier_increase : t -> int = function
  | Mountain -> raise BadTileInput
  | Empty | Fort -> 0
  | City i -> GameConstants.increase_soldier_factor * i

let upgrade_tile : t -> t = function
  | Mountain -> raise BadTileInput
  | Empty -> Fort
  | Fort -> City 1
  | City i -> City (i + 1)

let to_string : t -> string = function
  | Empty -> "TILE EMPTY"
  | Mountain -> "TILE MOUNTAIN"
  | Fort -> "TILE FORT"
  | City level -> "TILE CITY " ^ string_of_int level
