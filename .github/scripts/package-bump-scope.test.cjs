const assert = require("node:assert/strict");
const test = require("node:test");
const { classifyPackageBump } = require("./package-bump-scope.cjs");

test("accepts formula-only bumps", () => {
  assert.equal(classifyPackageBump(["Formula/one.rb", "Formula/two.rb"]), "formula");
});

test("accepts only the Open SWE Desktop cask", () => {
  assert.equal(classifyPackageBump(["Casks/open-swe-desktop.rb"]), "open-swe-desktop");
});

test("rejects empty, mixed, and unrelated changes", () => {
  assert.equal(classifyPackageBump([]), null);
  assert.equal(classifyPackageBump(["Formula/one.rb", "Casks/open-swe-desktop.rb"]), null);
  assert.equal(classifyPackageBump(["Casks/other.rb"]), null);
  assert.equal(classifyPackageBump(["README.md"]), null);
});
