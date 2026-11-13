"use strict";

console.group("Задача 1. Кодовый замок");
const lock = new CombinationLock(6, "821906", "797083");
console.log(lock.getMinimumMoves()); // 14
console.groupEnd();

console.group("Задача 2. Перевозка рабочих");
const firstTransport = new WorkerTransport(8, "2 3 4 4 1 2 3 1");
console.log(firstTransport.getMinimumCars()); // 5

const secondTransport = new WorkerTransport(12, "4 1 4 2 1 2 3 1 3 1 3 1");
console.log(secondTransport.getMinimumCars()); // 7
console.groupEnd();
