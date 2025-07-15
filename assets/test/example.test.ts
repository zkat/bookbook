import { deepStrictEqual } from "node:assert";
import { test } from "node:test";

test("example test", () => {
  deepStrictEqual({ foo: 1, bar: [2, 3] }, { foo: 1, bar: [2, 3] });
});
