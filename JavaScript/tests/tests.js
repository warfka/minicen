"use strict";

(() => {
  let passed = 0;
  let failed = 0;
  const lines = [];

  function assertEqual(actual, expected, message) {
    if (actual !== expected) {
      throw new Error(`${message}: ожидалось ${expected}, получено ${actual}.`);
    }
  }

  function assertThrows(action, errorType) {
    try {
      action();
    } catch (error) {
      if (error instanceof errorType) {
        return;
      }
      throw error;
    }

    throw new Error(`Ожидалась ошибка ${errorType.name}.`);
  }

  function test(name, action) {
    try {
      action();
      passed += 1;
      lines.push(`✓ ${name}`);
    } catch (error) {
      failed += 1;
      lines.push(`✗ ${name}: ${error.message}`);
      console.error(name, error);
    }
  }

  // Независимый эталон: поиск в ширину по состояниям одного диска.
  function findDiskDistance(start, target) {
    const queue = [[start, 0]];
    const visited = new Set([start]);

    for (let index = 0; index < queue.length; index += 1) {
      const [position, distance] = queue[index];
      if (position === target) {
        return distance;
      }

      for (const next of [(position + 1) % 10, (position + 9) % 10]) {
        if (!visited.has(next)) {
          visited.add(next);
          queue.push([next, distance + 1]);
        }
      }
    }
  }

  // Независимый эталон: полный перебор допустимых рассадок с отсечениями.
  function findMinimumCarsBySearch(groups) {
    const sorted = [...groups].sort((left, right) => right - left);
    const loads = [];
    let best = groups.length;

    function search(index) {
      if (index === sorted.length) {
        best = Math.min(best, loads.length);
        return;
      }
      if (loads.length >= best) {
        return;
      }

      const size = sorted[index];
      const visitedLoads = new Set();

      for (let car = 0; car < loads.length; car += 1) {
        if (loads[car] + size > 4 || visitedLoads.has(loads[car])) {
          continue;
        }

        visitedLoads.add(loads[car]);
        loads[car] += size;
        search(index + 1);
        loads[car] -= size;
      }

      loads.push(size);
      search(index + 1);
      loads.pop();
    }

    search(0);
    return best;
  }

  test("Замок: пример из задания", () => {
    assertEqual(new CombinationLock(6, "821906", "797083").getMinimumMoves(), 14, "Пример");
  });

  test("Замок: все 100 пар цифр совпадают с поиском в ширину", () => {
    for (let start = 0; start < 10; start += 1) {
      for (let target = 0; target < 10; target += 1) {
        const lock = new CombinationLock(1, String(start), String(target));
        assertEqual(lock.getMinimumMoves(), findDiskDistance(start, target), `${start} → ${target}`);
      }
    }
  });

  test("Замок: ведущие нули, одинаковые комбинации, 10 дисков", () => {
    assertEqual(new CombinationLock(4, "0009", "9990").getMinimumMoves(), 4, "Переход 0 ↔ 9");
    assertEqual(new CombinationLock(3, "007", "007").getMinimumMoves(), 0, "Замок открыт");
    assertEqual(new CombinationLock(10, "0000000000", "5555555555").getMinimumMoves(), 50, "Максимум");
    const lock = new CombinationLock(2, "09", "90");
    assertEqual(lock.getMinimumMoves(), 2, "Первый расчет");
    assertEqual(lock.getMinimumMoves(), 2, "Повторный расчет");
  });

  test("Замок: некорректные входные данные", () => {
    for (const count of [0, 11, 1.5, "1", NaN, Infinity]) {
      assertThrows(() => new CombinationLock(count, "0", "1"), RangeError);
    }
    assertThrows(() => new CombinationLock(2, "0", "01"), RangeError);
    assertThrows(() => new CombinationLock(2, "01", "1"), RangeError);
    for (const combination of [12, null, "", "1a", "-1", "1 ", "1\n"]) {
      assertThrows(() => new CombinationLock(2, combination, "01"), TypeError);
      assertThrows(() => new CombinationLock(2, "01", combination), TypeError);
    }
  });

  test("Перевозка: оба примера из задания", () => {
    assertEqual(new WorkerTransport(8, "2 3 4 4 1 2 3 1").getMinimumCars(), 5, "Первый пример");
    assertEqual(new WorkerTransport(12, "4 1 4 2 1 2 3 1 3 1 3 1").getMinimumCars(), 7, "Второй пример");
  });

  test("Перевозка: неделимость групп и заполнение свободных мест", () => {
    for (const [sizes, expected] of [
      ["3 3 2", 3],
      ["3 1", 1],
      ["2 2", 1],
      ["2 1 1", 1],
      ["2 1 1 1", 2],
      ["1 1 1 1 1", 2],
      ["3 3 1 1 1", 3],
      ["4", 1],
    ]) {
      assertEqual(new WorkerTransport(sizes.split(" ").length, sizes).getMinimumCars(), expected, sizes);
    }
  });

  test("Перевозка: все 1000 сочетаний из 1–10 групп совпадают с полным перебором", () => {
    let combinations = 0;
    for (let ones = 0; ones <= 10; ones += 1) {
      for (let twos = 0; twos <= 10 - ones; twos += 1) {
        for (let threes = 0; threes <= 10 - ones - twos; threes += 1) {
          for (let fours = 0; fours <= 10 - ones - twos - threes; fours += 1) {
            const groups = [
              ...Array(ones).fill(1),
              ...Array(twos).fill(2),
              ...Array(threes).fill(3),
              ...Array(fours).fill(4),
            ];
            if (groups.length === 0) {
              continue;
            }
            const input = groups.join(" ");
            const transport = new WorkerTransport(groups.length, input);
            assertEqual(transport.getMinimumCars(), findMinimumCarsBySearch(groups), input);
            combinations += 1;
          }
        }
      }
    }
    assertEqual(combinations, 1000, "Количество сочетаний");
  });

  test("Перевозка: 100 групп каждого размера", () => {
    for (const [size, expected] of [[1, 25], [2, 50], [3, 100], [4, 100]]) {
      const transport = new WorkerTransport(100, Array(100).fill(size).join(" "));
      assertEqual(transport.getMinimumCars(), expected, `100 групп по ${size}`);
    }
  });

  test("Перевозка: порядок групп, пробелы и повторный вызов", () => {
    const transport = new WorkerTransport(8, " 1  3\n2 1 4 4 3 2 ");
    assertEqual(transport.getMinimumCars(), 5, "Переставленные группы");
    assertEqual(transport.getMinimumCars(), 5, "Повторный расчет");
  });

  test("Перевозка: некорректные входные данные", () => {
    for (const count of [0, 101, 1.5, "1", NaN, Infinity]) {
      assertThrows(() => new WorkerTransport(count, "1"), RangeError);
    }
    for (const sizes of [null, [1], 1]) {
      assertThrows(() => new WorkerTransport(1, sizes), TypeError);
    }
    assertThrows(() => new WorkerTransport(2, "1"), RangeError);
    assertThrows(() => new WorkerTransport(1, "1 2"), RangeError);
    for (const sizes of ["", " ", "0", "5", "-1", "1.5", "1e0", "1x", "1,2"]) {
      assertThrows(() => new WorkerTransport(1, sizes), RangeError);
    }
  });

  const summary = `Пройдено: ${passed}. Ошибок: ${failed}.`;
  lines.push("", summary);
  document.getElementById("results").textContent = lines.join("\n");
  document.body.dataset.testStatus = failed === 0 ? "passed" : "failed";
  console.log(lines.join("\n"));

  if (failed > 0) {
    throw new Error(summary);
  }
})();
