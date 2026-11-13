"use strict";

class CombinationLock {
  #currentCombination;
  #secretCombination;

  constructor(diskCount, currentCombination, secretCombination) {
    if (!Number.isInteger(diskCount) || diskCount < 1 || diskCount > 10) {
      throw new RangeError("Количество дисков должно быть целым числом от 1 до 10.");
    }

    for (const combination of [currentCombination, secretCombination]) {
      if (typeof combination !== "string" || !/^[0-9]+$/.test(combination)) {
        throw new TypeError("Комбинация должна быть строкой из цифр от 0 до 9.");
      }

      if (combination.length !== diskCount) {
        throw new RangeError("Длина каждой комбинации должна совпадать с количеством дисков.");
      }
    }

    // Строки сохраняют ведущие нули, например "0009".
    this.#currentCombination = currentCombination;
    this.#secretCombination = secretCombination;
  }

  getMinimumMoves() {
    let moves = 0;

    for (let index = 0; index < this.#currentCombination.length; index += 1) {
      const difference = Math.abs(
        Number(this.#currentCombination[index]) - Number(this.#secretCombination[index]),
      );

      // Выбираем кратчайшее направление с учетом перехода между 9 и 0.
      moves += Math.min(difference, 10 - difference);
    }

    return moves;
  }
}
