const editorconfig = require('editorconfig')

async function run() {
  const args = process.argv
  const [, , filePath] = args

  try {
    const result = await editorconfig.parse(filePath)
    process.stdout.write(JSON.stringify(result) + '\n')
  } catch (err) {
    process.stderr.write(err + '\n')
  }
}
run()
