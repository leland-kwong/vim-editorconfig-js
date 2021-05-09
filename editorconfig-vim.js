async function run() {
  const args = process.argv
  const [, , filePath] = args
  const editorconfig = require('editorconfig')
  const promise = editorconfig.parse(filePath)

  promise
    .then(function onFulfilled(result) {
      process.stdout.write(JSON.stringify(result) + '\n')
    })
    .catch(function onError(err) {
      process.stderr.write(err + '\n')
    })
}
run()
