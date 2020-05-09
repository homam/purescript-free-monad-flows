import readline from 'readline'
export async function getLineUI() {
  return new Promise(resolve => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      terminal: false
    });

    rl.on('line', function (line) {
      resolve(line);
      rl.close()
    })
  })
}