# Composer.nvim

Basic plugin that returns that can query the composer.json file, return the values and generate namespaces

## Installation
```lua
use({"adalessa/composer.nvim"})
```

## Usage
```lua
-- Get the contents of the require field
require("composer").query({"require"})

-- Return the generated namespace for the current file
require("composer").namespace()
```
