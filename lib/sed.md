# <a id="top"></a>`shlib_sed_*`

[To main](./../readme.md)

* [Intro](#intro)
* [`shlib_sed_escape_rex`](#escape-rex)
* [`shlib_sed_escape_replace`](#escape-replace)

## Intro

TBD

[To top]

## <a id="escape-rex"></a>`shlib_sed_escape_rex`

Escape REX for sed regex value

**Aliases**: `sed_escape_rex`

**Dependencies**: `excode`

### Usage

```sh
shlib_sed_escape_rex [-r|--retvar RETVAR] [--] REX
```

### Options

```
-r, --retvar  variable name that will contain the result
```

### Exit codes

* [`SHLIB_OK`](./excode.md#shlib_ok)
* [`SHLIB_ERRSYS`](./excode.md#shlib_errsys)

### Demo

```sh
declare escaped_rex
sed_escape_rex -r escaped_rex "*"
sed 's/'"${escaped_rex}"'//g' <<< 'rm "*" occurrences'

escaped_rex="$(sed_escape_rex "*")"
sed 's/'"${escaped_rex}"'//g' <<< 'rm "*" occurrences'
```

[To top]

## <a id="escape-replace"></a>`shlib_sed_escape_replace`

Escape REPLACE for sed replace value

**Aliases**: `sed_escape_replace`

**Dependencies**: `excode`

### Usage

```sh
shlib_sed_escape_replace [-r|--retvar RETVAR] [--] REPLACE
```

### Options

```
-r, --retvar  variable name that will contain the result
```

### Exit codes

* [`SHLIB_OK`](./excode.md#shlib_ok)
* [`SHLIB_ERRSYS`](./excode.md#shlib_errsys)

### Demo

```sh
declare escaped_replace
sed_escape_replace -r escaped_replace "/"
sed 's/a/'"${escaped_replace}"'/g' <<< 'replace "a" with "/"'

escaped_replace="$(sed_escape_replace "/")"
sed 's/a/'"${escaped_replace}"'/g' <<< 'replace "a" with "/"'
```

[To top]

[To top]: #top
