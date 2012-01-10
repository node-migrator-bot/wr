#-------------------------------------------------------------------------------
# Copyright (c) 2012 Patrick Mueller
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------

fs       = require 'fs'
path     = require 'path'

charm    = require 'charm'
optimist = require 'optimist'

wr       = require './wr'

charm = charm(process.stderr)

#-------------------------------------------------------------------------------
exports.run = ->

    argv = process.argv.slice(2)

    if argv.length == 0
        if path.existsSync('.wr')
            stats = fs.statSync('.wr')
            if stats.isFile()
                argv = getDotWrContents(".wr")

    argv = optimist
        .usage('Usage: $0 [-cvV] command [file ...]')
        .boolean( 'v')
        .boolean( 'verbose')
        .alias(   'v', 'verbose')
        .describe('v', 'generate verbose diagnostics')

        .alias(   'c', 'chime')
        .describe('c', 'generate a diagnostic every so many minutes')

        .boolean( 'V')
        .describe('V', 'print the version')

        .boolean( '?')
        .describe('?', 'print help')

        .boolean( 'h')
        .describe('h', 'print help')

        .parse(argv)

    #----

    printHelp() if argv["?"] or argv.h

    if argv.V
        console.log(getVersion())
        process.exit 0

    args = argv._

    printHelp() if args.length == 0

    cmd = args[0]

    printHelp() if cmd == '?'

    if args.length == 1
        files = ["."]
    else
        files = args.slice(1)

    #----

    { verbose, chime } = argv
    opts = {verbose, chime, logError, logSuccess, logInfo}

    wr.run cmd, files, opts

#-------------------------------------------------------------------------------
printHelp = (argv) ->
    optimist.showHelp()

    console.error "for more info see: https://github.com/pmuellr/wr"

    process.exit 1

#-------------------------------------------------------------------------------
getDotWrContents = () ->
    contents = fs.readFileSync('.wr', 'utf8')
    lines    = contents.split('\n')

    args = []
    for line in lines
        line = line.replace(/#.*/,'')
        line = line.replace(/(^\s+)|(\s+$)/g,'')
        continue if line == ''

        args.push line

    args

#-------------------------------------------------------------------------------
getVersion = () ->

    packageJsonName  = path.join(path.dirname(fs.realpathSync(__filename)), '../package.json')

    json = fs.readFileSync(packageJsonName, 'utf8')
    values = JSON.parse(json)

    return values.version

#---------------------------------------------------------------------------
logError = (message) ->
    message = "wr: #{message}"
    charm
        .push(true)
        .display('bright')
        .background('red')
        .foreground('white')
        .write(message)
        .pop(true)
        .write('\n')
        .down(1)

#---------------------------------------------------------------------------
logSuccess = (message) ->
    message = "wr: #{message}"
    charm
        .push(true)
        .display('bright')
        .background('green')
        .foreground('white')
        .write(message)
        .pop(true)
        .write('\n')
        .down(1)

#---------------------------------------------------------------------------
logInfo = (message) ->
    message = "wr: #{message}"
    charm
        .push(true)
        .display('bright')
        .background('blue')
        .foreground('white')
        .write(message)
        .pop(true)
        .write('\n')
        .down(1)
