const FORMULA = /^Formula\/[^/]+\.rb$/;
const OPEN_SWE_DESKTOP = "Casks/open-swe-desktop.rb";

function classifyPackageBump(files) {
  if (files.length === 0) return null;
  if (files.every((file) => FORMULA.test(file))) return "formula";
  if (files.length === 1 && files[0] === OPEN_SWE_DESKTOP) return "open-swe-desktop";
  return null;
}

module.exports = { classifyPackageBump };
