const readline = require("readline");
const { LispTokenizer } = require("./tokenizer");
const { evalNode, createGlobalEnv } = require("./evaluator");
const { parseTokens } = require("./parser"); // ensure parser exports a parse function

const env = createGlobalEnv();
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: "elisp> "
});

rl.prompt();

rl.on("line", (line) => {
    try {
        const tokenizer = new LispTokenizer(line);
        const tokens = tokenizer.tokenize();
        const ast = parseTokens(tokens); // top-level AST
        const result = ast.map(node => evalNode(node, env));
        console.log(result[result.length - 1]);
    } catch (err) {
        console.error("Error:", err.message);
    }
    rl.prompt();
});
