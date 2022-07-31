# <a id="top"></a>`shlib_msgbag_*`

[To main](./../README.md)

* [intro](#intro)
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

For **array** `BAGREF` messages are kept just as array items.

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

For the first message line there is a `*{space}` prefix and the next lines of the message are prepended with the same number of spaces as the charecters count in the first line prefix. Thus multiline messages are allowed.

For that reason `shlib_msgbag_*` in most cases work faster with **array** `BAGREF`, as there is less additional string processing.

In most demos **string** `BAGREF` will be used.

[To top]

## <a id="add"></a>`shlib_msgbag_add`

Add MSG messages to BAGREF message bag

Aliases: `msgbag_add`

```sh
shlib_msgbag_add BAGREF [MSG...]
```

### Options

None

### Return codes

* `0 `- operation successful
* `1 `- no messages to add in the input (silent), or runtime error from (printed to `stderr`)

### Demo

```sh
declare messenger1
# add 2 messages to empty messenger1
shlib_msgbag_add messenger1 "message 1" "message 2"
# add 3-d message to messenger1
shlib_msgbag_add messenger1 "multiline
message"

declare messenger2
# output: "No messages added"
# as there is no messages provieded
shlib_msgbag_add messenger2 || echo "No messages added"
```

[To top]

## <a id="from_list"></a>`shlib_msgbag_from_list`

Load BAGREF message bag from LISTFILE files and / or stdin  
Aliases: `list2msgbag`
```sh
shlib_msgbag_from_list [-p|--prefix PREFIX] [--] [-] BAGREF \
  [LISTFILE...] [<<< 'MSG...']
```

[To top]

## <a id="len"></a>`shlib_msgbag_len`

Get BAGREF message bag messages count  
Aliases: `msgbag_len`
```sh
shlib_msgbag_len [-r|--retvar RETVAR] BAGREF
```

[To top]

[To top]: #top
