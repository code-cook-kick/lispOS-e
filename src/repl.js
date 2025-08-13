const readline = require("readline");
const { LispTokenizer } = require("./tokenizer");
const { evalNode, createGlobalEnv } = require("./evaluator");
const { LispParser } = require("./parser");

const env = createGlobalEnv();
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: "elisp> "
});

rl.prompt();

rl.on("line", (line) => {
    try {
        const parser = new LispParser(line);
        const ast = parser.parse(); // returns array of top-level AST nodes
        const result = ast.map(node => evalNode(node, env));
        console.log(result[result.length - 1]);
    } catch (err) {
        console.error("Error:", err.message);
    }
    rl.prompt();
});
