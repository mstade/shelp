# yaml2sh: Parses simple yaml into shell format

I found myself having the need for declaring simple properties files quite often and while writing simple shell variables into a file and sourcing that often works well, it's not always as readable as I'd wish. Because of this, I wrote an awk script that will read a specified file and output a format suitable for shell consumption.

## Installation
1. Download [yaml2sh](https://github.com/mstade/shelp/raw/master/yaml2sh/yaml2sh)
2. Make it executable: chmod +x yaml2sh

## Usage
### Parsing a file to stdout
```sh
yaml2sh myfile
```

### Parsing a file, storing the result in another file
```sh
yaml2sh myfile > somefile
```

### Parsing a file and sourcing the result to shell variables
```sh
source `yaml2sh myfile`
```

# YAML support
The yaml2sh script can't parse any YAML, it only supports a subset. This may change in the future.

## Key/value pairs:
Simple key value pairs will be turned into simple variables, where the key is variable name (verbatim) and the value is, well, the value.

```yaml
key: value
```

```sh
key="value"
```

## Inline lists:
Inline lists are supported and will be outputted as a simple shell array.

```yaml
key: [value1, value2, value3]
```

```sh
key=( "value1" "value2" "value3" )
```
