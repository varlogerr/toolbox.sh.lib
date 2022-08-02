# <a id="top"></a>`shlib_list_*`

[**< To main**](./../readme.md)

* [Intro](#intro)
* [`shlib_list_from_args`](#from-args)
* [`shlib_arr_from_list`](#from-list)

## Intro

TBD

[^ To top]

## <a id="from-args"></a>`shlib_list_from_args`

Convert `ITEM`s to text list

**Aliases**: `args2list`

**Dependencies**: `shlib_excode`

### Usage

```sh
shlib_list_from_args [-r|--retvar RETVAR] \
  [-p|--prefix PREFIX] [--offset OFFSET] \
  [--] [ITEM...]
```

### Options

```
--            end of option arguments
-r, --retvar  variable name that will contain the result
-p, --prefix  list item prefix, defaults to '* '
--offset      offset length for not prefixed lines,
              defaults to PREFIX length
```

### Exit codes

* [`SHLIB_OK`](./excode.md#shlib_ok)
* [`SHLIB_ERRSYS`](./excode.md#shlib_errsys)

### Demo

```sh
declare -a args=(1 "2"$'\n'3)

# outputs:
# * 1
# * 2
#   3
args2list -- "${args[0]}" "${args[1]}"

# outputs:
# - 1
# - 2
#   3
args2list -p '- ' -- "${args[@]}"

# outputs:
# * 1
# * 2
#     3
declare retvar
args2list -r retvar --offset 4 -- "${args[@]}" >/dev/null
printf '%s\n' "${retvar}"
```

[^ To top]

## <a id="TBD"></a>`TBD`

TBD

**Aliases**: `TBD`

**Dependencies**: TBD

### Usage

```sh
TBD
```

### Options

TBD

### Exit codes

TBD

### Demo

```sh
TBD
```

[^ To top]

[^ To top]: #top
