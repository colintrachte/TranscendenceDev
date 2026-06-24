# TLisp Style Guidelines

For a language introduction see the [TLisp Programmer Guide](../Programmer_Guides/Tlisp.md).

## Compatibility

Functions in game data are organized by stability tier. Use the appropriate
prefix so callers know what to expect:

| Prefix | Meaning |
|--------|---------|
| `int`  | Internal — may change between API versions without notice |
| `rpg`  | RPG-layer library function — stable within an API version |
| `math` | General math utilities |
| `obj`  | General object utilities |
| `scr`  | Dock screen utilities |
| `str`  | String utilities |
| `sys`  | Star system utilities |

Global variables use a `g` prefix: `gPlayerShip`, `gSource`, `gItem`.

When writing functions intended for use by extensions (mods), prefer the `rpg`
or utility prefixes and document any API version requirements in a comment.

## Formatting

### Indentation

Use **tabs** at 4 spaces, matching the C++ style. Each closing parenthesis that
opens a new logical block should be on its own line, aligned with the opening
statement — mirroring the Whitesmith brace style used in C++:

```lisp
(block (
    (result 0)
    )
    (setq result (+ result 1))
    result
    )
```

### Lambda Definitions

Assign lambdas with `setq`. Put the parameter list on the same line as `lambda`;
put the body indented on the next line:

```lisp
(setq myFunction (lambda (argA argB)
    (block (
        (temp (+ argA argB))
        )
        temp
        )
    ))
```

### `block` Usage

Use `(block Nil ...)` when you have no local variables. Use
`(block (vars) ...)` to declare locals. Declare all locals at the top of the
block rather than inline:

```lisp
; Good — locals at the top
(block (
    (speed (obj@ targetObj 'maxSpeed))
    (distance (sysVectorDistance fromVec toVec))
    )
    (sysCalcTravelTime distance speed)
    )

; Avoid — locals mixed into body
(block Nil
    (setq speed (obj@ targetObj 'maxSpeed))
    (setq distance (sysVectorDistance fromVec toVec))
    (sysCalcTravelTime distance speed)
    )
```

### Conditionals

Prefer `switch` over nested `if` for multiple branches. `switch` evaluates each
condition in order and returns the value of the first matching branch:

```lisp
(switch
    (isInt thePriceAdj)
        (divide (multiply thePriceAdj basePrice) 100)

    (isFunction thePriceAdj)
        (apply thePriceAdj theItem Nil)

    ; Default
    basePrice
    )
```

Use `if` for simple two-branch cases:

```lisp
(if (gr encounterCount 0)
    (/ 1 (+ encounterCount 1))
    0
    )
```

### Comments

Within a TLisp block, use semicolon comments:

```lisp
; This is a section comment

(setq result (+ a b))  ; inline comment
```

Outside a TLisp block, use XML comments:

```xml
<!-- This describes the following block -->
<Globals>
    (block Nil
        ; TLisp comments inside
        )
</Globals>
```

Do not use semicolon comments to comment out XML syntax — the parser still reads
those lines. Use `<!-- -->` for XML-level comments.

### Naming

- Functions: `camelCase` with a module prefix (`rpgDoThing`, `intCalcFoo`)
- Local variables: short `camelCase` without prefix (`theItem`, `speed`, `i`)
- Loop counters: single letters (`i`, `j`) for numeric loops
- Parameters: descriptive `camelCase` matching the role (`targetObj`, `encounterCount`)
- Event-context globals: `gSource` (the object receiving the event), `gItem`,
  `gPlayerShip` — use these as-is, never shadow them with local variables of the
  same name

### Line Length

There is no hard limit, but prefer splitting long expressions across lines rather
than letting them run past ~100 characters. Put each argument on its own line
when a call has more than three arguments or when the expression is already
nested:

```lisp
(sysAddEncounterEventAtDist
    encounterTime
    targets
    encounterID
    110
    )
```

### Struct Literals

Inline struct literals `{ key: value }` are fine for small, readable records.
For structs with many fields, put each field on its own line:

```lisp
{
theItem: theItem
needed: (itmGetCount theItem)
avail: (or (objHasItem sourceObj theItem 1) 0)
}
```
