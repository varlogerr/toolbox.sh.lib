# <a id="top"></a>`shlib_msgbag_*`

[To main](./../readme.md)

* [Intro](#intro)
* [Exit codes](#exit-codes)
* [`shlib_msgbag_add`](#add)
* [`shlib_msgbag_from_list`](#from_list)
* [`shlib_msgbag_len`](#len)

## Intro

`msgbag` is a special structure for keeping messages. 

`msgbag` reference (or `BAGREF`) can be used in three forms:

* **string**. In this case the variable itself is used for `BAGREF`:
  ```sh
  declare str_bag
  shlib_msgbag_add str_bag ...
  ```

* **array**. In this case the variable itself is used for `BAGREF`:
  ```sh
  declare -a arr_bag
  shlib_msgbag_add arr_bag ...
  ```

* **assoc array**. In this case a variable key is used for `BAGREF`:
  ```sh
  declare -A assoc_bag
  shlib_msgbag_add assoc_bag[some_key] ...
  ```
  In case of **assoc array** `BAGREF` it allows to keep multiple categories of messages under a single variable.
  ```sh
  declare -A assoc_bag
  shlib_msgbag_add assoc_bag[errors] "error1" "error2" ...
  shlib_msgbag_add assoc_bag[successes] "success1" "success2" ...
  ```

For **array** `BAGREF` messages are kept in array items.

For **string** and **assoc array** `BAGREF` keeps messages in the following format:

```txt
* msg1 first line
  msg1 second line
  ...
* msg2 first line
  msg2 second line
  ...
* msg3 single line
```

For the first message line there is a '`* `' (i.e. asterisk followed by space) prefix and the next lines of the message are prepended with the same number of spaces as the charecters count in the first line prefix. Thus multiline messages are allowed.

For that reason `shlib_msgbag_*` in most cases work faster with **array** `BAGREF`, as there is less additional string processing.

In most demos **string** `BAGREF` will be used.

Be careful with `*REF` variable names, as `shlib_msgbag_*` functions fail silently with `0` exit code when `*REF` is an invalid variable name.

```sh
if ! shlib_msgbag_add - "error1" "error2"; then
  [[ ${?} -eq 125 ]] && echo "Invalid BAGREF name"
fi
```

[^ To top]

## Exit codes

Exported variables can be used to detect what kind of problem occured. Available exit codes exported variables:

```
SHLIB_MSGBAG_OK       (0)   - all is fine
SHLIB_MSGBAG_NOMSG    (1)   - no message
SHLIB_MSGBAG_NOFILE   (2)   - file is not available / can't be read
SHLIB_MSGBAG_INVLINE  (4)   - invalid line in messages list
                      (8)   - 
                      (16)  - 
                      (32)  - 
                      (64)  - 
```

Exit codes are bitwise OR-ed, so they can be decoded.

```sh
shlib_msgbag_* ...
rc=$?

[[ $((rc | $SHLIB_MSGBAG_NO_MSG)) -eq $rc ]] \
  && echo "No message" >&2

[[ $((rc | $SHLIB_MSGBAG_NO_FILE)) -eq $rc ]] \
  && echo "No file" >&2
```

The only exclusion for exit code combination is `SHLIB_MSGBAG_BADREF`, it halts functions immediately.

[^ To top]

## <a id="add"></a>`shlib_msgbag_add`

Add MSG messages to BAGREF message bag

**Aliases**: `msgbag_add`

### Usage

```sh
shlib_msgbag_add BAGREF [MSG...]
```

### Options

None

### Exit codes

* [`SHLIB_OK`](./excode.md#shlib_ok)
* [`SHLIB_ERRSYS`](./excode.md#shlib_errsys)

### Demo

```sh
declare messenger1

# add 2 messages to empty messenger1
msgbag_add messenger1 "message 1" "message 2"

# add 3-d message to messenger1
msgbag_add messenger1 "multiline
message"
```

[^ To top]

## <a id="from_list"></a>`shlib_msgbag_from_list`

Add messages to `BAGREF` message bag read from LISTFILE files and / or stdin. List item is detected by `PREFIX` in an item first line.

Aliases: `list2msgbag`

```sh
shlib_msgbag_from_list [-p|--prefix PREFIX] \
  [-e|--errbag ERRBAG] [--] [-] \
  BAGREF [LISTFILE...] [<<< 'MSGLIST']
```

### Options

```
-p, --prefix  list item prefix, defaults to '* '
-e, --errbag  must be assoc array instance of MSGBAG
--            end of option arguments
-             stdin placeholder
```

### Exit codes

* `SHLIB_MSGBAG_OK`
* `SHLIB_MSGBAG_NOMSG`
* `SHLIB_MSGBAG_NOFILE`
* `SHLIB_MSGBAG_INVLINE`

`SHLIB_MSGBAG_NOFILE` is not fatal, the commmand will just skip the missing file.

### Demo

```sh
# cat lst1.txt
* message 1 line 1
  message 1 line 2
* message 2 line 1

# cat lst2.txt
-   message 1 line 1
    message 1 line 2
-   message 2 line 1

# cat lst3.txt
* message 1 line 1
invalid line
* message 2 line 1
```
```sh
declare messenger1

# add 2 messages to messenger1
list2msgbag messenger1 lst1.txt

# add 2 messages
list2msgbag -p '-   ' messenger1 lst2.txt

# read from stdin
list2msgbag messenger1 <<< "$(cat lst1.txt)"

# read from a file and stdin (will result in
# adding list from lst1.txt twice)
list2msgbag messenger1 - lst1.txt <<< "$(cat lst1.txt)"

declare -A errbag

# don't alter messenger1 and fail with
# ${SHLIB_MSGBAG_INVLINE} exit code due to invalid
# line in lst3.txt file
list2msgbag -p '-   ' -e errbag messenger1 \
  lst1.txt lst3.txt || {
    [[ ${rc} -eq ${SHLIB_MSGBAG_INVLINE} ]] && {
      echo "Invalid lines are:" >&2
      # errbag[invline] contains invalid lines from
      # lst3.txt file
      msgbag2list errbag[invline] >&2
    }
  }

# add lists from existing files and exit with
# ${SHLIB_MSGBAG_NOFILE} exit code for not
# existing nofile.txt
list2msgbag -p '-   ' -e errbag messenger1 \
  lst1.txt nofile.txt || {
    [[ ${rc} -eq ${SHLIB_MSGBAG_NOFILE} ]] && {
      echo "Invalid files are:" >&2
      # errbag[nofile] contains invalid files
      msgbag2list errbag[nofile] >&2
    }
  }
```

[To top]

## <a id="len"></a>`shlib_msgbag_len`

Get count of messages in the BAGREF message bag

Aliases: `msgbag_len`

```sh
shlib_msgbag_len [-r|--retvar RETVAR] BAGREF
```

### Options

```
-r, --retvar  variable name that will contain the result
```

### Exit codes

* `SHLIB_MSGBAG_OK`
* `SHLIB_MSGBAG_NOMSG`

### Demo

```sh
declare messenger1
msgbag_add messenger1 "one" "two"

# output length to stdout
msgbag_len messenger1

declare messenger1_len
# put to RETVAR and output it
msgbag_len -r messenger1_len messenger1 > /dev/null
echo ${messenger1_len}
```

[^ To top]

[^ To top]: #top
