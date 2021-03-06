import { Component, OnInit } from '@angular/core';
import { LocalModeNetworkService } from './local-mode-network.service';
import { GameState } from '../game-state';
import { GameStatus } from '../definitions';
import { sleep } from '../util';
import { GameBoard } from '../game-board';

@Component({
  selector: 'app-local-mode',
  templateUrl: './local-mode.component.html',
  styleUrls: ['./local-mode.component.css']
})
export class LocalModeComponent implements OnInit {

  /**
   * Report whether the player is in a game.
   */
  private _inGame: boolean;
  /**
   * Report whether the player is in game but game has now stopped.
   */
  private _inGameAndStopped: boolean;
  /**
   * The current game state.
   */
  private readonly _gameState: GameState;

  /**
   * Construct itself from supporting services.
   *
   * @param {LocalModeNetworkService} networkService the network service.
   */
  constructor(private networkService: LocalModeNetworkService) {
    this._inGame = false;
    this._inGameAndStopped = false;
    this._gameState = new GameState();
  }

  ngOnInit() {
  }

  /**
   * Report whether the player is in game.
   *
   * @returns {boolean} whether the player is in game.
   */
  get isInGame(): boolean {
    return this._inGame;
  }

  /**
   * Report whether the player is in game but game stopped.
   *
   * @returns {boolean} whether the player is in game but game stopped.
   */
  get isInGameButStopped(): boolean {
    return this._inGameAndStopped;
  }

  /**
   * Obtain the current game board.
   *
   * @returns {GameBoard} the current game board.
   */
  get game(): GameBoard {
    return this._gameState.gameBoard;
  }

  /**
   * Start to make query to the server.
   */
  private makeQuery(): void {
    this.networkService.query(this._gameState.gameBoard.numberOfTurns,
      report => {
        this._gameState.applyChanges(report);
        if (report.status === GameStatus.IN_PROGRESS) {
          this._inGame = true;
          this._inGameAndStopped = false;
          sleep(400).then(() => this.makeQuery());
        } else {
          this._inGame = true;
          this._inGameAndStopped = true;
        }
      });
  }

  /**
   * Handle when the program gets submitted.
   *
   * @param {[string]} programs a tuple of black and white programs.
   */
  programSubmitted(programs: [string, string]): void {
    const blackProgram = programs[0], whiteProgram = programs[1];
    this.networkService.startSimulation(blackProgram, whiteProgram,
      isSuccessful => {
        if (isSuccessful) {
          this._inGame = true;
          this.makeQuery();
        } else {
          this._inGame = false;
          alert('Your code does not compile!');
        }
      });
  }

  /**
   * Reset the status to a new game.
   */
  reset(): void {
    this._inGame = false;
    this._inGameAndStopped = false;
    this._gameState.reset();
  }

  /**
   * Replay the entire game. It can be called only after game finished.
   */
  replay(): void {
    this._inGame = true;
    this._inGameAndStopped = false;
    this._gameState.replay(() => {
      this._inGameAndStopped = true;
    });
  }

}
