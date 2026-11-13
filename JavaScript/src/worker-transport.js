"use strict";

class WorkerTransport {
  #groupCounts = [0, 0, 0, 0, 0];

  constructor(groupCount, groupSizes) {
    if (!Number.isInteger(groupCount) || groupCount < 1 || groupCount > 100) {
      throw new RangeError("Количество групп должно быть целым числом от 1 до 100.");
    }

    if (typeof groupSizes !== "string") {
      throw new TypeError("Размеры групп должны быть строкой чисел, разделенных пробелами.");
    }

    const sizes = groupSizes.trim().split(/\s+/);

    if (sizes.length !== groupCount) {
      throw new RangeError("Количество размеров групп должно совпадать с количеством групп.");
    }

    for (const size of sizes) {
      if (!/^[1-4]$/.test(size)) {
        throw new RangeError("Размер каждой группы должен быть целым числом от 1 до 4.");
      }

      this.#groupCounts[Number(size)] += 1;
    }
  }

  getMinimumCars() {
    let singleGroups = this.#groupCounts[1];
    const doubleGroups = this.#groupCounts[2];

    // Группам из четырех и трех человек нужна отдельная машина.
    let cars = this.#groupCounts[4] + this.#groupCounts[3];

    // В каждую машину с тройкой можно посадить одну группу из одного человека.
    singleGroups = Math.max(0, singleGroups - this.#groupCounts[3]);

    // Две группы по два человека полностью занимают машину.
    cars += Math.floor(doubleGroups / 2);

    if (doubleGroups % 2 !== 0) {
      cars += 1;
      // Оставшуюся двойку дополняем максимум двумя одиночными группами.
      singleGroups = Math.max(0, singleGroups - 2);
    }

    return cars + Math.ceil(singleGroups / 4);
  }
}
