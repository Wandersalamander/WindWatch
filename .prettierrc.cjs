// Resolved via NODE_PATH, which pre-commit points at its node env.
// Prettier itself only looks for plugins in the project directory.
module.exports = {
  plugins: [require.resolve("@markw65/prettier-plugin-monkeyc")],
};
