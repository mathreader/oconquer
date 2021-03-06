(**
 * [User] module is responsible for dealing with the user registration, signing
 * in, and validation.
*)

(** [user] is the abstract type of the user object. *)
type user

(**
 * [token user] reports the token of the user [user].
 *
 * Requires: [user] is a legal user.
 * @return the token of the user [user].
*)
val token : user -> int

(**
 * [Elo] module is responsible for the computation of ELO rating.
 * @see <https://en.wikipedia.org/wiki/Elo_rating_system> Wikipedia Page, where
 * we find the basic idea of the algorithm.
 * @see <https://www.geeksforgeeks.org/elo-rating-algorithm/> GeeksForGeeks,
 * where we base our implementation on.
*)
module Elo : sig

  (**
   * [update_rating p1_wins (rating1, rating2)] gives the new ratings after
   * a game, in which its result has been indicated by [p1_wins]. Old ratings
   * [(rating1, rating2)] are provided to help determine the new ratings.
   *
   * Requires:
   * - [p1_wins] represents whether player 1 (with [rating1]) wins. If it wins,
   *   then the value should be [1.]. If it loses, then the value should be
   *   [0.]. If there is a draw, then the value should be 0.5.
   * - [rating1, rating2] are ratings of player 1 and player 2.
   * @return a pair of updated ratings.
  *)
  val update_rating : float -> float * float -> float * float

end

(**
 * [Database] is the module that handles the in-memory database operation
 * related to users. The database will be indexed by the users.
*)
module Database : sig
  (** [t] is the abstract type for the user database object. *)
  type t

  (** [empty] is the empty user database. *)
  val empty : t

  (**
   * [register username password db] tries to register for a new user with given
   * [username] and [password] in the given database [db].
   *
   * Requires:
   * - [username] and [password] can be any string.
   * - [db] must be a legal database.
   * @return [None] if registration failed due to duplicate username;
   * [Some (db, token)] when it succeeds and gives back new database [db] and
   * token [token] for the new user.
  *)
  val register : string -> string -> t -> (t * int) option

  (**
   * [sign_in username password db] tries to sign in for the user and give
   * the signed in user's token.
   *
   * Requires:
   * - [username] and [password] can be any string.
   * - [db] must be a legal database.
   * @return [None] if signing in failed due to wrong username and password;
   * [Some token] when it succeeds and gives back the token [token] for the
   * signed-in user.
  *)
  val sign_in : string -> string -> t -> int option

  (**
   * [has_token token db] checks whether the given [token] is in [db].
   *
   * Requires:
   * - [token] can be any int.
   * - [db] must be a legal database.
   * @return whether the given [token] is in [db].
  *)
  val has_token : int -> t -> bool

  (**
   * [get_user_by_token token db] obtains the user with [token] in [db].
   *
   * Requires:
   * - [token] must be an existing user token.
   * - [db] must be a legal database.
   * @return [Some user] where the user has the given [token] or [None] if there
   * is no such user.
  *)
  val get_user_opt_by_token : int -> t -> user option

  (**
   * [update_rating game_result black_token white_token db] updates and creates
   * a new DB that reflected the updated ratings.
   *
   * Requires:
   * - [game_result] cannot be [InProgress].
   * - [black_token] and [white_token] must be the token of existing user.
   * - [db] is a legal database.
   * @return the new database with the updated game ratings.
  *)
  val update_rating : Definitions.game_status -> int -> int -> t -> t

  (**
   * [score_board db] gives the json representation of the score board.
   *
   * Requires: [db] is a legal database.
   * @return json representation of the score board.
  *)
  val score_board : t -> Yojson.Basic.json
end


(** [MatchMaking] is a module for matching making between players. *)
module MatchMaking : sig

  (**
   * [player] contains the basic user info and the programs submitted by the
   * user.
  *)
  type player

  (** [queue] is the abstract type of the matching queue. *)
  type queue

  (**
   * [create_player user black_program white_program] creates a player from
   * the user info [user] and [black_program] and [white_program].
   *
   * Requires:
   * - [user] is a legal user object.
   * - [black_program] and [white_program] can be any string.
   * @return the created player with above-mentioned info.
  *)
  val create_player : user -> string -> string -> player

  (**
   * [get_user_from_player player] obtains the user info from [player].
   *
   * Requires: [player] is a legal player.
   * @return user info of the player.
  *)
  val get_user_from_player : player -> user

  (**
   * [get_black_program_from_player player] obtains the black program from
   * [player].
   *
   * Requires: [player] is a legal player.
   * @return the black program of the player.
  *)
  val get_black_program_from_player : player -> string

  (**
   * [get_white_program_from_player player] obtains the white program from
   * [player].
   *
   * Requires: [player] is a legal player.
   * @return the black program of the player.
  *)
  val get_white_program_from_player : player -> string

  (** [empty_queue] is an empty matching queue. *)
  val empty_queue : queue

  (**
   * [accept_and_form_match new_player queue] accepts a new player into the
   * [queue] and immediately tries to form a match.
   * The resultant match and the queue without the matched will be given back.
   *
   * Requires:
   * - [new_player] is a legal player.
   * - [queue] is a legal queue.
   * @return if a match cannot be formed, [(None, queue')] will be given where
   * [queue'] if the queue with the added player. Else, [Some (p1, p2), queue']
   * will be returned, where [p1] [p2] are the matched players and [queue'] is
   * the queue with [new_player] added and [p1] [p2] removed.
  *)
  val accept_and_form_match : player
    -> queue -> (player * player) option * queue

end
