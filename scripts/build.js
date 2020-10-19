// Constants
const project_name = 'cyberdeck';

// Output directory
const build_dir = './build';

// Output file (contains debug functions)
const debug_output = build_dir+'/debug.lua'

// Source file of debugging functions
const debug_functions_file = './src/debug_functions.lua';

// Output file of release
const compiled_output = build_dir+'/main.lua';

// Source of polyfill functions to make the project lua compatible
const love_polyfill_file = './src/polyfill.lua';

// Source file of pico-8 headers
const pico_header_file = './src/pico_header.lua';

// Source file of pico-8 controller code
const pico_controller = './src/pico_controller.lua';

// Output file for pico-8
const pico_output = build_dir+'/'+project_name+'.p8';

// Listing of all project sources
const source_files = [
  './src/constants.lua',
  './src/globals.lua',
  './src/system.lua',
  './src/view.lua'
];

// Requires
const fs = require('fs');
const strip = require('strip-comments');
const strip_opts = {'language':'lua'};

// Create the build directory
if (!fs.existsSync(build_dir)){
  fs.mkdirSync(build_dir);
}

// Function to concatenate files.
function concat_files(filelist, output_file) {
  let content = '';
  for(i=0;i<filelist.length;i++) {
    content += fs.readFileSync(filelist[i], 'utf8') + '\n';
  }
  if (output_file) {
    fs.writeFileSync(output_file, content);
  }
  return content;
}

// Combine all sources.
concat_files(source_files, compiled_output);

// Pico build: Affix a header then strip comments and blank lines.
let p8_content = concat_files([pico_header_file, compiled_output, pico_controller]);
p8_content = strip(p8_content, strip_opts).replace(/^\s*[\r\n]/gm,"");
fs.writeFileSync(pico_output, p8_content);

// Love build: Affix a polyfill to make pico-8 code Lua compatible.
concat_files([compiled_output, love_polyfill_file], compiled_output);

// Debug build: Append debug functions.
concat_files([compiled_output, debug_functions_file], debug_output)
